#!/bin/bash
# FLIPOP Firebase 셋업 스크립트
# 사용법: ./scripts/firebase_setup.sh
set -euo pipefail

echo "=== FLIPOP Firebase Setup ==="

# 1. Firebase CLI 확인
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI가 설치되어 있지 않습니다."
    echo "   npm install -g firebase-tools"
    exit 1
fi
echo "✅ Firebase CLI: $(firebase --version)"

# 2. Firebase 프로젝트 확인
PROJECT_ID="flipop-game"
echo "📦 프로젝트: $PROJECT_ID"
firebase use $PROJECT_ID 2>/dev/null || firebase use --add $PROJECT_ID

# 3. Firestore 보안 규칙 배포
echo "🔒 Firestore 보안 규칙 배포..."
cat > firestore.rules << 'RULES'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 유저 프로필: 본인만 읽기/쓰기
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // 순위표: 인증된 사용자 읽기, 본인만 쓰기
    match /leaderboard/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.data.bestScore is int
                   && request.resource.data.bestScore >= 0
                   && request.resource.data.nickname is string
                   && request.resource.data.nickname.size() <= 12;
    }
  }
}
RULES

# 4. Firestore 인덱스
echo "📋 Firestore 인덱스 설정..."
cat > firestore.indexes.json << 'INDEXES'
{
  "indexes": [
    {
      "collectionGroup": "leaderboard",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "bestScore", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
INDEXES

# 5. firebase.json 업데이트
echo "⚙️  firebase.json 업데이트..."
cat > firebase.json << 'CONFIG'
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "flutter": {
    "platforms": {
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "flipop-game",
          "configurations": {
            "android": {
              "default": {
                "appId": "1:576288394502:android:0b4933ed836c18ddd8a287",
                "projectId": "flipop-game"
              }
            },
            "ios": {
              "default": {
                "appId": "1:576288394502:ios:f935ff9bb7376a38d8a287",
                "projectId": "flipop-game"
              }
            }
          }
        }
      }
    }
  }
}
CONFIG

# 6. 배포
echo "🚀 Firestore 규칙 + 인덱스 배포..."
firebase deploy --only firestore:rules,firestore:indexes --project $PROJECT_ID

echo ""
echo "=== ✅ Firebase 셋업 완료! ==="
echo "  - Firestore 규칙: 배포됨"
echo "  - Firestore 인덱스: 배포됨"
echo "  - 프로젝트: $PROJECT_ID"
