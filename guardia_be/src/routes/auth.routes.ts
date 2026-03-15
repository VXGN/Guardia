import { Router } from "express";
import { AuthController } from "../controllers/auth.controller";
import { validate } from "../middlewares/validate.middleware";
import { registerSchema, verifyTokenSchema } from "../validators/auth.validator";

const router = Router();
const controller = new AuthController();

router.post("/register", validate(registerSchema), controller.register);
router.post("/verify", validate(verifyTokenSchema), controller.verify);

export { router as authRoutes };
