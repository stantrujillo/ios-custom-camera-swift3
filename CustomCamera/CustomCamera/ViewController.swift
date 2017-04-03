//
//  ViewController.swift
//  CustomCamera
//
//  Created by Adarsh V C on 06/10/16.
//  Copyright © 2016 FAYA Corporation. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

	@IBOutlet weak var imgOverlay: UIImageView!
	@IBOutlet weak var btnCapture: UIButton!

	let captureSession = AVCaptureSession()
	let stillImageOutput = AVCaptureStillImageOutput()
	var previewLayer : AVCaptureVideoPreviewLayer?

	var captureDevice : AVCaptureDevice?

	fileprivate var timer: Timer!

	override func viewDidLoad()
	{
		super.viewDidLoad()

//		captureSession.sessionPreset = AVCaptureSessionPresetPhoto

		for device in AVCaptureDevice.devices() as! [AVCaptureDevice]
		{
			if (device.position == AVCaptureDevicePosition.back)
			{
				print("self.view.frame: \(self.view.frame)")
				captureDevice = device
				beginSession()

			}
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

			stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]

			if captureSession.canAddOutput(stillImageOutput)
			{
				captureSession.addOutput(stillImageOutput)
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

	func saveToCamera()
	{
		if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo)
		{
			stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
				if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer)
				{
					if let cameraImage = UIImage(data: imageData)
					{
						UIImageWriteToSavedPhotosAlbum(cameraImage, nil, nil, nil)
					}
				}
			})
		}
	}
}


