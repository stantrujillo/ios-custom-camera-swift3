//
//  ViewController.swift
//  CustomCamera
//
//  Created by Adarsh V C on 06/10/16.
//  Copyright © 2016 FAYA Corporation. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class ViewController: UIViewController, AVCapturePhotoCaptureDelegate
{
	@IBOutlet weak var imgOverlay: UIImageView!
	@IBOutlet weak var btnCapture: UIButton!

	let captureSession = AVCaptureSession()
	let capturePhotoOutout = AVCapturePhotoOutput()
	var previewLayer : AVCaptureVideoPreviewLayer?

	var captureDevice : AVCaptureDevice?

	fileprivate var timer: Timer!

	override func viewDidLoad()
	{
		super.viewDidLoad()

		if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
		{
			captureDevice = device
			beginSession()
		}
	}

	override func viewDidAppear(_ animated: Bool)
	{
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: fireTimer)
	}

	override func viewDidDisappear(_ animated: Bool)
	{
		timer?.invalidate()
	}

	fileprivate func fireTimer(timer: Timer)
	{
		print("tick")
	}

	@IBAction func actionCameraCapture(_ sender: AnyObject)
	{
		print("Camera button pressed")
		saveToCamera()
	}

	func beginSession()
	{
		do
		{
			try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))

			if captureSession.canAddOutput(capturePhotoOutout)
			{
				captureSession.addOutput(capturePhotoOutout)
			}
		}
		catch
		{
			print("error: \(error.localizedDescription)")
		}

		guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else
		{
			print("no preview layer")
			return
		}

		self.view.layer.addSublayer(previewLayer)
		print("self.view.layer.frame: \(self.view.layer.frame)")
		let frame = CGRect(x: 0, y: 20, width: self.view.layer.frame.width, height: self.view.layer.frame.height - 40)
		previewLayer.frame = frame
		captureSession.startRunning()

		self.view.addSubview(imgOverlay)
		self.view.addSubview(btnCapture)
	}

	func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?)
	{
		if let error = error
		{
			print(error.localizedDescription)
		}

		if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer)
		{
			if let image = UIImage(data: dataImage)
			{
				UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
			}
		}
	}

	func saveToCamera()
	{
		let settings = AVCapturePhotoSettings()
		let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
		let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
		                     kCVPixelBufferWidthKey as String: 160,
		                     kCVPixelBufferHeightKey as String: 160]
		settings.previewPhotoFormat = previewFormat
		self.capturePhotoOutout.capturePhoto(with: settings, delegate: self)
	}
}


