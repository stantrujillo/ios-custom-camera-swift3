//
//  ViewController.swift
//  CustomCamera
//
//  Stan Trujillo on 23/10/17.
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

		if let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
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
		print("timer tick...")
	}

	@IBAction func actionCameraCapture(_ sender: AnyObject)
	{
		saveToCamera()
	}

	func beginSession()
	{
		// these are necessary to get full resolution 4:3 output
		capturePhotoOutout.isHighResolutionCaptureEnabled = true
		captureSession.sessionPreset = AVCaptureSession.Preset.photo

		do
		{
			try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!))

			if captureSession.canAddOutput(capturePhotoOutout)
			{
				captureSession.addOutput(capturePhotoOutout)
			}
		}
		catch
		{
			print("error: \(error.localizedDescription)")
		}

		let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

		self.view.layer.addSublayer(previewLayer)
		previewLayer.frame = self.view.layer.frame

		captureSession.startRunning()

		self.view.addSubview(imgOverlay)
		self.view.addSubview(btnCapture)
	}

	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?)
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
				print("image saved (\(image.size.width) x \(image.size.height))")
			}
		}
	}
	
	func saveToCamera()
	{
		let settings = AVCapturePhotoSettings()

		settings.isHighResolutionPhotoEnabled = true

		// The preview is not used in this example, but it isn't clear how to suppress it...
		settings.previewPhotoFormat = [
			kCVPixelBufferPixelFormatTypeKey as String: settings.availablePreviewPhotoPixelFormatTypes.first!,
			kCVPixelBufferWidthKey as String: 160,
			kCVPixelBufferHeightKey as String: 160
		]

		self.capturePhotoOutout.capturePhoto(with: settings, delegate: self)
	}
}


