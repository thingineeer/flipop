"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onUserDeleted = void 0;
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
/**
 * Auth 삭제 트리거 → users + leaderboard 문서 삭제
 */
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
    const uid = user.uid;
    const batch = db.batch();
    batch.delete(db.collection("users").doc(uid));
    batch.delete(db.collection("leaderboard").doc(uid));
    await batch.commit();
    functions.logger.info(`Deleted data for user ${uid}`);
});
//# sourceMappingURL=index.js.map