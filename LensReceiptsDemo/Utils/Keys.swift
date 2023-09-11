//
//  Keys.swift
//  LensReceiptsDemo
//
//  Created by Sebastian Giraldo on 5/10/22.
//

import Foundation

enum Keys: String {
    case autoDocDetectionAndCropIsOn
    case autoDeleteAfterProcessing
    case autoLightDetectionIsOn
    case autoRotateIsOn
    case autoSkewCorrectionIsOn
    case autoCropGalleryIsOn
    case autoCropBrowserIsOn
    case autoCaptureIsOn
    case autoSubmitDocumentOnCapture
    case blurDetectionIsOn
    case boostModeIsOn
    case boundingBoxesIsOn
    case backupDocsToGallery
    case browseIsOn
    case categories
    case checksBackIsOn
    case cleanBorderIsOn
    case closeCameraOnSubmit
    case confidenceDetailsIsOn
    case dataExtractionEngine
    case defaultSelectedDocumentType
    case detectBlurResponseIsOn
    case dictateIsOn
    case allowSubmitUndetectedDocsIsOn
    case documentTypes
    case docDetectFillUIColor
    case docDetectStrokeUIColor
    case emailCCIsOn
    case emailCCDomain
    case externalId
    case galleryIsOn
    case gpuIsOn
    case isReimbursableDefault
    case isProduction
    case locationServicesIsOn
    case manualCropIsOn
    case moreMenuIsOn
    case moreSettingsMenuIsOn
    case multipleDocumentsIsOn
    case originalImageMaxSizeInMB
    case parseAddressIsOn
    case rotateDocIsOn
    case returnStitchedPDF
    case saveLogsIsOn
    case shareLogsIsOn
    case stitchIsOn
    case showDocumentTypes
    case shieldProtectionIsOn
    case stitchedPDFPixelDensityMultiplier
    case submitButtonBackgroundColor
    case submitButtonBorderColor
    case submitButtonCornerRadius
    case submitButtonFontColor
    case categoryName
    case tagName
    case costCodes
    case customers
    case tags
    case categoriesList
}

enum Types {
    case switchCell
    case doubleValueCell
    case integerValueCell
    case stringValueCell
    case stringColorCell
}
