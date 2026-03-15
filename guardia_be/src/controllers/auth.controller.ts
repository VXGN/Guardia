import { Request, Response } from "express";
import { AuthService } from "../services/auth.service";
import { sendCreated, sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";

const authService = new AuthService();

export class AuthController {
  register = asyncHandler(async (req: Request, res: Response) => {
    const result = await authService.register(req.body);
    sendCreated(res, result, "User registered successfully");
  });

  verify = asyncHandler(async (req: Request, res: Response) => {
    const { token } = req.body;
    const result = await authService.verifyToken(token);
    sendSuccess(res, result, "Token verified successfully");
  });
}
