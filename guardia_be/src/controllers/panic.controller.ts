import { Response } from "express";
import { PanicService } from "../services/panic.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";
import type { AuthenticatedRequest } from "../middlewares/auth.middleware";

const panicService = new PanicService();

export class PanicController {
  trigger = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await panicService.triggerPanic(req.uid!, req.body);
    sendSuccess(res, result, result.message);
  });

  start = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await panicService.triggerPanic(req.uid!, req.body);
    sendSuccess(res, result, "Panic session started");
  });

  cancel = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await panicService.cancelPanic(req.uid!, req.body);
    sendSuccess(res, result, result.message);
  });

  updateLocation = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await panicService.updatePanicLocation(req.uid!, req.body);
    sendSuccess(res, result, "Panic location updated");
  });

  getEmergencyPinHash = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await panicService.getEmergencyPinHash(req.uid!);
    sendSuccess(res, result, "Emergency PIN hash retrieved");
  });
}
