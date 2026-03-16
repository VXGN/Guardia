import { Response } from "express";
import { UploadService } from "../services/upload.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";
import type { AuthenticatedRequest } from "../middlewares/auth.middleware";
import { BadRequestError } from "../utils/errors";

const uploadService = new UploadService();

export class UploadController {
  uploadSingle = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    if (!req.file) {
      throw new BadRequestError("No file uploaded");
    }

    const url = await uploadService.uploadFile(req.file);
    sendSuccess(res, { url }, "File uploaded successfully");
  });

  uploadMultiple = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const files = req.files as Express.Multer.File[];
    if (!files || files.length === 0) {
      throw new BadRequestError("No files uploaded");
    }

    const urls = await uploadService.uploadMultiple(files);
    sendSuccess(res, { urls }, "Files uploaded successfully");
  });
}
