package y0;

import android.accounts.Account;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.text.TextUtils;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.internal.F;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.concurrent.locks.ReentrantLock;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: renamed from: y0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0738b {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final ReentrantLock f6806c = new ReentrantLock();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static C0738b f6807d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ReentrantLock f6808a = new ReentrantLock();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final SharedPreferences f6809b;

    public C0738b(Context context) {
        this.f6809b = context.getSharedPreferences("com.google.android.gms.signin", 0);
    }

    public static C0738b a(Context context) {
        F.g(context);
        ReentrantLock reentrantLock = f6806c;
        reentrantLock.lock();
        try {
            if (f6807d == null) {
                f6807d = new C0738b(context.getApplicationContext());
            }
            C0738b c0738b = f6807d;
            reentrantLock.unlock();
            return c0738b;
        } catch (Throwable th) {
            reentrantLock.unlock();
            throw th;
        }
    }

    public static final String f(String str, String str2) {
        StringBuilder sb = new StringBuilder(str.length() + 1 + String.valueOf(str2).length());
        sb.append(str);
        sb.append(":");
        sb.append(str2);
        return sb.toString();
    }

    public final GoogleSignInAccount b() {
        String strD;
        String strD2 = d("defaultGoogleSignInAccount");
        if (TextUtils.isEmpty(strD2) || (strD = d(f("googleSignInAccount", strD2))) == null) {
            return null;
        }
        try {
            return GoogleSignInAccount.b(strD);
        } catch (JSONException unused) {
            return null;
        }
    }

    public final void c(GoogleSignInAccount googleSignInAccount, GoogleSignInOptions googleSignInOptions) {
        F.g(googleSignInAccount);
        F.g(googleSignInOptions);
        String str = googleSignInAccount.f3337o;
        e("defaultGoogleSignInAccount", str);
        String strF = f("googleSignInAccount", str);
        JSONObject jSONObject = new JSONObject();
        try {
            String str2 = googleSignInAccount.f3331b;
            if (str2 != null) {
                jSONObject.put("id", str2);
            }
            String str3 = googleSignInAccount.f3332c;
            if (str3 != null) {
                jSONObject.put("tokenId", str3);
            }
            String str4 = googleSignInAccount.f3333d;
            if (str4 != null) {
                jSONObject.put("email", str4);
            }
            String str5 = googleSignInAccount.e;
            if (str5 != null) {
                jSONObject.put("displayName", str5);
            }
            String str6 = googleSignInAccount.f3339q;
            if (str6 != null) {
                jSONObject.put("givenName", str6);
            }
            String str7 = googleSignInAccount.f3340r;
            if (str7 != null) {
                jSONObject.put("familyName", str7);
            }
            Uri uri = googleSignInAccount.f3334f;
            if (uri != null) {
                jSONObject.put("photoUrl", uri.toString());
            }
            String str8 = googleSignInAccount.f3335m;
            if (str8 != null) {
                jSONObject.put("serverAuthCode", str8);
            }
            jSONObject.put("expirationTime", googleSignInAccount.f3336n);
            jSONObject.put("obfuscatedIdentifier", str);
            JSONArray jSONArray = new JSONArray();
            ArrayList arrayList = googleSignInAccount.f3338p;
            Scope[] scopeArr = (Scope[]) arrayList.toArray(new Scope[arrayList.size()]);
            Arrays.sort(scopeArr, x0.d.f6760b);
            for (Scope scope : scopeArr) {
                jSONArray.put(scope.f3371b);
            }
            jSONObject.put("grantedScopes", jSONArray);
            jSONObject.remove("serverAuthCode");
            e(strF, jSONObject.toString());
            String strF2 = f("googleSignInOptions", str);
            String str9 = googleSignInOptions.f3354n;
            String str10 = googleSignInOptions.f3353m;
            ArrayList arrayList2 = googleSignInOptions.f3349b;
            JSONObject jSONObject2 = new JSONObject();
            try {
                JSONArray jSONArray2 = new JSONArray();
                Collections.sort(arrayList2, GoogleSignInOptions.f3347w);
                Iterator it = arrayList2.iterator();
                while (it.hasNext()) {
                    jSONArray2.put(((Scope) it.next()).f3371b);
                }
                jSONObject2.put("scopes", jSONArray2);
                Account account = googleSignInOptions.f3350c;
                if (account != null) {
                    jSONObject2.put("accountName", account.name);
                }
                jSONObject2.put("idTokenRequested", googleSignInOptions.f3351d);
                jSONObject2.put("forceCodeForRefreshToken", googleSignInOptions.f3352f);
                jSONObject2.put("serverAuthRequested", googleSignInOptions.e);
                if (!TextUtils.isEmpty(str10)) {
                    jSONObject2.put("serverClientId", str10);
                }
                if (!TextUtils.isEmpty(str9)) {
                    jSONObject2.put("hostedDomain", str9);
                }
                e(strF2, jSONObject2.toString());
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
        } catch (JSONException e4) {
            throw new RuntimeException(e4);
        }
    }

    public final String d(String str) {
        ReentrantLock reentrantLock = this.f6808a;
        reentrantLock.lock();
        try {
            return this.f6809b.getString(str, null);
        } finally {
            reentrantLock.unlock();
        }
    }

    public final void e(String str, String str2) {
        ReentrantLock reentrantLock = this.f6808a;
        reentrantLock.lock();
        try {
            this.f6809b.edit().putString(str, str2).apply();
        } finally {
            reentrantLock.unlock();
        }
    }
}
