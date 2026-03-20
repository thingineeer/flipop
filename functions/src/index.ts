import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

/**
 * Auth 삭제 트리거 → users + leaderboard 문서 삭제
 */
export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  const batch = db.batch();

  batch.delete(db.collection("users").doc(uid));
  batch.delete(db.collection("leaderboard").doc(uid));

  await batch.commit();
  functions.logger.info(`Deleted data for user ${uid}`);
});

/**
 * 점수 제출 (서버사이드 검증)
 *
 * 검증 항목:
 * 1. 인증된 사용자만 허용
 * 2. 점수 범위 검증 (0 ~ MAX_SCORE)
 * 3. 제출 쿨다운 (10초)
 * 4. 닉네임 정규식 검증
 * 5. 기존 점수보다 높은 경우에만 갱신
 */
const MAX_SCORE = 999999; // 이론적 최대 점수
const SUBMIT_COOLDOWN_MS = 10000; // 10초 쿨다운

export const submitScore = functions.https.onCall(async (data, context) => {
  // 1. 인증 확인
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "인증이 필요합니다."
    );
  }

  const uid = context.auth.uid;
  const { score, nickname, avatarId, countryCode } = data;

  // 2. 입력 검증
  if (typeof score !== "number" || !Number.isInteger(score)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "점수는 정수여야 합니다."
    );
  }
  if (score < 0 || score > MAX_SCORE) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      `점수는 0 ~ ${MAX_SCORE} 범위여야 합니다.`
    );
  }
  if (typeof nickname !== "string" || !/^[가-힣a-zA-Z0-9]{2,12}$/.test(nickname)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "닉네임 형식이 올바르지 않습니다."
    );
  }
  if (typeof avatarId !== "string" || avatarId.length === 0 || avatarId.length > 20) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "아바타 ID가 올바르지 않습니다."
    );
  }
  if (countryCode !== undefined && countryCode !== null) {
    if (typeof countryCode !== "string" || !/^[A-Z]{2}$/.test(countryCode)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "국가 코드가 올바르지 않습니다."
      );
    }
  }

  // 3. 기존 문서 확인 (쿨다운 + 베스트 점수)
  const docRef = db.collection("leaderboard").doc(uid);
  const doc = await docRef.get();

  if (doc.exists) {
    const docData = doc.data()!;
    const lastUpdated = docData.updatedAt?.toDate();

    // 쿨다운 체크
    if (lastUpdated) {
      const elapsed = Date.now() - lastUpdated.getTime();
      if (elapsed < SUBMIT_COOLDOWN_MS) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          "점수 제출이 너무 빈번합니다. 잠시 후 다시 시도해주세요."
        );
      }
    }

    // 기존 점수보다 낮으면 스킵
    const currentBest = docData.bestScore as number ?? 0;
    if (score <= currentBest) {
      return { updated: false, bestScore: currentBest };
    }
  }

  // 4. 점수 저장
  const writeData: Record<string, unknown> = {
    nickname,
    avatarId,
    bestScore: score,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (countryCode) {
    writeData.countryCode = countryCode;
  }

  await docRef.set(writeData, { merge: true });
  functions.logger.info(`Score submitted: uid=${uid}, score=${score}`);

  return { updated: true, bestScore: score };
});
