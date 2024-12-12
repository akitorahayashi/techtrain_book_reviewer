## アカウント登録時の認証要素
### 名前

**形式**:
1. 空白は含んでいても反映される。
2. 空白を削除した後、空でないこと。
3. 空白を含め **10文字** 以内であること。

**例**:
- 正しい: `JohnDoe`
- 正しい: `Alice`
- 誤り: `          `（空白のみ）
- 誤り: `ThisNameIsTooLong`（11文字以上）

#### 名前を変更する際にもこのバリデーションは適用される

---

### メールアドレス

**形式**:
1. **ローカル部分**（`@`の前）:
    - 英数字、ドット（`.`）、アンダースコア（`_`）、ハイフン（`-`）、プラス（`+`）などを使用可能。
2. **`@`記号**:
    - 必須。
3. **ドメイン部分**（`@`の後）:
    - 英数字とドット（`.`）で構成。
    - トップレベルドメイン（例: `.com`, `.jp`）は2文字以上。
4. 空白を含んでいた場合、削除される。

**例**:
- 正しい: `example@example.com`
- 正しい: `user.name+tag@domain.co.jp`
- 誤り: `example.com`（`@`がない）
- 誤り: `user@.com`（ドメインが不正）

---

### パスワード

**形式**:
1. 最小 **6文字** 以上であること。
2. 空白を削除した後、空でないこと。
3. 空白を含んでいた場合、削除される。
4. 2回入力して検証

**例**:
- 正しい: `password123`
- 正しい: `secure_pass`
- 誤り: `abc`（6文字未満）
- 誤り: `       `（空白のみ）

---