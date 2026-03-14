import { Router } from "express";
import { PanicController } from "../controllers/panic.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import { triggerPanicSchema } from "../validators/panic.validator";

const router = Router();
const controller = new PanicController();

router.use(authMiddleware);

router.post("/trigger", validate(triggerPanicSchema), controller.trigger);

export { router as panicRoutes };
