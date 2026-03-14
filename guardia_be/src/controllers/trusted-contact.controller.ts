import { Response } from "express";
import { TrustedContactService } from "../services/trusted-contact.service";
import { sendSuccess, sendCreated, sendNoContent } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";
import type { AuthenticatedRequest } from "../middlewares/auth.middleware";

const trustedContactService = new TrustedContactService();

export class TrustedContactController {
  list = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const contacts = await trustedContactService.list(req.uid!);
    sendSuccess(res, contacts, "Trusted contacts retrieved successfully");
  });

  create = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const contact = await trustedContactService.create(req.uid!, req.body);
    sendCreated(res, contact, "Trusted contact created successfully");
  });

  update = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const { id } = req.params;
    const contact = await trustedContactService.update(req.uid!, id, req.body);
    sendSuccess(res, contact, "Trusted contact updated successfully");
  });

  delete = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const { id } = req.params;
    await trustedContactService.delete(req.uid!, id);
    sendNoContent(res);
  });
}
