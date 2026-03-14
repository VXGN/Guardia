import { Response } from "express";
import { ProfileService } from "../services/profile.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";
import type { AuthenticatedRequest } from "../middlewares/auth.middleware";

const profileService = new ProfileService();

export class ProfileController {
  getProfile = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const profile = await profileService.getProfile(req.uid!);
    sendSuccess(res, profile, "Profile retrieved successfully");
  });

  updateProfile = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const profile = await profileService.updateProfile(req.uid!, req.body);
    sendSuccess(res, profile, "Profile updated successfully");
  });
}
