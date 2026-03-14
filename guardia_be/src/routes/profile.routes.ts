import { Router } from "express";
import { ProfileController } from "../controllers/profile.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import { updateProfileSchema } from "../validators/profile.validator";

const router = Router();
const controller = new ProfileController();

router.use(authMiddleware);

router.get("/", controller.getProfile);
router.put("/", validate(updateProfileSchema), controller.updateProfile);

export { router as profileRoutes };
