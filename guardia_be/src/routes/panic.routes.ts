import { Router } from "express";
import { PanicController } from "../controllers/panic.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import {
	triggerPanicSchema,
	cancelPanicSchema,
	updatePanicLocationSchema,
} from "../validators/panic.validator";

const router = Router();
const controller = new PanicController();

router.use(authMiddleware);

router.post("/trigger", validate(triggerPanicSchema), controller.trigger);
router.post("/start", validate(triggerPanicSchema), controller.start);
router.post("/update-location", validate(updatePanicLocationSchema), controller.updateLocation);
router.post("/cancel", validate(cancelPanicSchema), controller.cancel);
router.get("/emergency-pin-hash", controller.getEmergencyPinHash);

export { router as panicRoutes };
