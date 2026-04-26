package e1;

import A.J;
import A.L;
import A.M;
import A.X;
import I.C0053n;
import J3.u;
import a.AbstractC0184a;
import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.res.Resources;
import android.graphics.Point;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
import android.os.ParcelFileDescriptor;
import android.os.Process;
import android.os.StrictMode;
import android.text.TextUtils;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.internal.p002firebaseauthapi.zzafj;
import com.google.android.gms.tasks.Task;
import com.google.android.recaptcha.RecaptchaAction;
import com.google.crypto.tink.shaded.protobuf.S;
import com.google.firebase.auth.FirebaseAuth;
import j3.C0468e;
import java.io.ByteArrayInputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.spec.ECPoint;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.crypto.Mac;
import javax.crypto.SecretKey;
import l1.C0522a;
import l1.r;
import m0.C0545a;
import m3.InterfaceC0555b;
import m3.InterfaceC0556c;
import o.AbstractFutureC0576h;
import o.C0572d;
import o.C0575g;
import o3.C0590F;
import o3.C0592H;
import o3.I;
import t2.C0676a;
import t2.C0677b;
import t2.C0678c;
import t2.C0680e;
import t2.C0681f;
import t2.C0682g;
import t2.C0683h;
import t2.C0684i;
import t2.EnumC0679d;
import u2.EnumC0691a;
import u3.AbstractC0692a;
import x3.AbstractC0726f;
import y1.AbstractC0752b;
import y3.C0768i;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z3.C0790b;
import z3.C0791c;
import z3.C0792d;
import z3.C0793e;

/* JADX INFO: loaded from: classes.dex */
public abstract class k {
    public static final void A(ByteBuffer byteBuffer, ByteBuffer byteBuffer2, int i4, int i5) {
        int iLimit = byteBuffer2.limit();
        byteBuffer2.position(i4);
        byteBuffer2.limit(i4 + i5);
        byteBuffer.put(byteBuffer2);
        byteBuffer2.limit(iLimit);
    }

    public static void D(Throwable th) {
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        th.printStackTrace(printWriter);
        printWriter.flush();
        J3.i.d(stringWriter.toString(), "toString(...)");
    }

    public static String E(String str) {
        J3.i.e(str, "s");
        try {
            MessageDigest messageDigest = MessageDigest.getInstance("MD5");
            byte[] bytes = str.getBytes(P3.a.f1492a);
            J3.i.d(bytes, "getBytes(...)");
            messageDigest.update(bytes);
            byte[] bArrDigest = messageDigest.digest();
            G3.a aVar = G3.c.e;
            J3.i.b(bArrDigest);
            return G3.c.b(aVar, bArrDigest);
        } catch (Exception unused) {
            return "";
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:8:0x0014  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object F(io.ktor.network.sockets.y r7, X3.d r8, I.C0053n r9, A3.c r10) throws java.lang.Throwable {
        /*
            boolean r0 = r10 instanceof o3.J
            if (r0 == 0) goto L14
            r0 = r10
            o3.J r0 = (o3.J) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L14
            int r1 = r1 - r2
            r0.e = r1
        L12:
            r6 = r0
            goto L1a
        L14:
            o3.J r0 = new o3.J
            r0.<init>(r10)
            goto L12
        L1a:
            java.lang.Object r10 = r6.f6016d
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r6.e
            r2 = 1
            if (r1 == 0) goto L3d
            if (r1 != r2) goto L35
            io.ktor.utils.io.m r7 = r6.f6015c
            io.ktor.utils.io.m r8 = r6.f6014b
            io.ktor.network.sockets.y r9 = r6.f6013a
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Throwable -> L31
            r3 = r7
            r7 = r9
            goto L6a
        L31:
            r0 = move-exception
            r10 = r0
            r1 = r9
            goto L7a
        L35:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r8)
            throw r7
        L3d:
            e1.AbstractC0367g.M(r10)
            java.lang.String r10 = "<this>"
            J3.i.e(r7, r10)
            r10 = r2
            io.ktor.utils.io.m r2 = new io.ktor.utils.io.m
            r2.<init>()
            r7.j(r2)
            io.ktor.utils.io.m r3 = new io.ktor.utils.io.m
            r3.<init>()
            r7.u(r3)
            r6.f6013a = r7     // Catch: java.lang.Throwable -> L76
            r6.f6014b = r2     // Catch: java.lang.Throwable -> L76
            r6.f6015c = r3     // Catch: java.lang.Throwable -> L76
            r6.e = r10     // Catch: java.lang.Throwable -> L76
            r1 = r7
            r5 = r8
            r4 = r9
            java.lang.Object r10 = e1.AbstractC0367g.z(r1, r2, r3, r4, r5, r6)     // Catch: java.lang.Throwable -> L72
            if (r10 != r0) goto L68
            return r0
        L68:
            r7 = r1
            r8 = r2
        L6a:
            io.ktor.network.sockets.y r10 = (io.ktor.network.sockets.y) r10     // Catch: java.lang.Throwable -> L6d
            return r10
        L6d:
            r0 = move-exception
            r10 = r0
            r1 = r7
        L70:
            r7 = r3
            goto L7a
        L72:
            r0 = move-exception
            goto L78
        L74:
            r8 = r2
            goto L70
        L76:
            r0 = move-exception
            r1 = r7
        L78:
            r10 = r0
            goto L74
        L7a:
            r8.t(r10)
            io.ktor.utils.io.z.b(r7, r10)
            r1.close()
            throw r10
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.k.F(io.ktor.network.sockets.y, X3.d, I.n, A3.c):java.lang.Object");
    }

    public static boolean G(View view, InterfaceC0556c interfaceC0556c) {
        if (view != null) {
            if (interfaceC0556c.a(view)) {
                return true;
            }
            if (view instanceof ViewGroup) {
                ViewGroup viewGroup = (ViewGroup) view;
                for (int i4 = 0; i4 < viewGroup.getChildCount(); i4++) {
                    if (G(viewGroup.getChildAt(i4), interfaceC0556c)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public static ArrayList H(Throwable th) {
        ArrayList arrayList = new ArrayList(3);
        if (th instanceof C0468e) {
            C0468e c0468e = (C0468e) th;
            arrayList.add(c0468e.f5236a);
            arrayList.add(c0468e.getMessage());
            arrayList.add(null);
            return arrayList;
        }
        arrayList.add(th.toString());
        arrayList.add(th.getClass().getSimpleName());
        arrayList.add("Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
        return arrayList;
    }

    public static ArrayList I(Throwable th) {
        ArrayList arrayList = new ArrayList(3);
        arrayList.add(th.toString());
        arrayList.add(th.getClass().getSimpleName());
        arrayList.add("Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
        return arrayList;
    }

    public static Object J(I3.p pVar, Object obj, InterfaceC0762c interfaceC0762c) {
        J3.i.e(pVar, "<this>");
        InterfaceC0767h context = interfaceC0762c.getContext();
        Object c0792d = context == C0768i.f6945a ? new C0792d(interfaceC0762c) : new C0793e(interfaceC0762c, context);
        u.a(2, pVar);
        return pVar.invoke(obj, c0792d);
    }

    public static final void K(Z3.a aVar, byte[] bArr, int i4) {
        int i5 = (i4 + 7) >>> 3;
        int length = bArr.length;
        int i6 = 0;
        while (true) {
            if (i6 >= length) {
                i6 = -1;
                break;
            } else if (bArr[i6] != 0) {
                break;
            } else {
                i6++;
            }
        }
        int length2 = i5 - (bArr.length - i6);
        if (length2 > 0) {
            AbstractC0692a.c(aVar, new byte[length2], 0, length2);
        }
        AbstractC0692a.c(aVar, bArr, i6, bArr.length - i6);
    }

    public static final void L(Z3.a aVar, ECPoint eCPoint, int i4) {
        Z3.a aVar2 = new Z3.a();
        aVar2.n((byte) 4);
        byte[] byteArray = eCPoint.getAffineX().toByteArray();
        J3.i.d(byteArray, "toByteArray(...)");
        K(aVar2, byteArray, i4);
        byte[] byteArray2 = eCPoint.getAffineY().toByteArray();
        J3.i.d(byteArray2, "toByteArray(...)");
        K(aVar2, byteArray2, i4);
        aVar.n((byte) AbstractC0692a.a(aVar2));
        AbstractC0692a.d(aVar, aVar2);
    }

    /* JADX WARN: Removed duplicated region for block: B:16:0x0043 A[PHI: r2 r9 r10
      0x0043: PHI (r2v10 io.ktor.utils.io.v) = (r2v8 io.ktor.utils.io.v), (r2v12 io.ktor.utils.io.v) binds: [B:34:0x00ce, B:15:0x003a] A[DONT_GENERATE, DONT_INLINE]
      0x0043: PHI (r9v9 int) = (r9v7 int), (r9v10 int) binds: [B:34:0x00ce, B:15:0x003a] A[DONT_GENERATE, DONT_INLINE]
      0x0043: PHI (r10v7 o3.K) = (r10v5 o3.K), (r10v9 o3.K) binds: [B:34:0x00ce, B:15:0x003a] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:26:0x0097  */
    /* JADX WARN: Removed duplicated region for block: B:30:0x00ae A[PHI: r2 r9 r10
      0x00ae: PHI (r2v8 io.ktor.utils.io.v) = (r2v13 io.ktor.utils.io.v), (r2v14 io.ktor.utils.io.v) binds: [B:28:0x00ab, B:17:0x0047] A[DONT_GENERATE, DONT_INLINE]
      0x00ae: PHI (r9v7 int) = (r9v5 int), (r9v8 int) binds: [B:28:0x00ab, B:17:0x0047] A[DONT_GENERATE, DONT_INLINE]
      0x00ae: PHI (r10v5 o3.K) = (r10v3 o3.K), (r10v6 o3.K) binds: [B:28:0x00ab, B:17:0x0047] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:33:0x00cd  */
    /* JADX WARN: Removed duplicated region for block: B:39:0x00e3 A[PHI: r9 r10
      0x00e3: PHI (r9v11 int) = (r9v9 int), (r9v14 int) binds: [B:37:0x00e0, B:14:0x0031] A[DONT_GENERATE, DONT_INLINE]
      0x00e3: PHI (r10v10 io.ktor.utils.io.v) = (r10v12 io.ktor.utils.io.v), (r10v13 io.ktor.utils.io.v) binds: [B:37:0x00e0, B:14:0x0031] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:42:0x00f3 A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object M(io.ktor.utils.io.C0449m r9, o3.K r10, A3.c r11) {
        /*
            Method dump skipped, instruction units count: 262
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.k.M(io.ktor.utils.io.m, o3.K, A3.c):java.lang.Object");
    }

    public static final void N(Z3.a aVar, I i4, int i5) throws C0590F {
        J3.i.e(i4, "type");
        if (i5 > 16777215) {
            throw new C0590F(S.d(i5, "TLS handshake size limit exceeded: "), 0);
        }
        int i6 = (i4.f6012a << 24) | i5;
        Z3.f fVarH = aVar.h(4);
        int i7 = fVarH.f2616c;
        byte[] bArr = fVarH.f2614a;
        bArr[i7] = (byte) ((i6 >>> 24) & 255);
        bArr[i7 + 1] = (byte) ((i6 >>> 16) & 255);
        bArr[i7 + 2] = (byte) ((i6 >>> 8) & 255);
        bArr[i7 + 3] = (byte) (i6 & 255);
        fVarH.f2616c = i7 + 4;
        aVar.f2603c += 4;
    }

    public static Status O(String str) {
        String str2;
        if (TextUtils.isEmpty(str)) {
            return new Status(17499, null);
        }
        String[] strArrSplit = str.split(":", 2);
        strArrSplit[0] = strArrSplit[0].trim();
        if (strArrSplit.length > 1 && (str2 = strArrSplit[1]) != null) {
            strArrSplit[1] = str2.trim();
        }
        List listAsList = Arrays.asList(strArrSplit);
        return listAsList.size() > 1 ? P((String) listAsList.get(0), (String) listAsList.get(1)) : P((String) listAsList.get(0), null);
    }

    public static Status P(String str, String str2) {
        int i4;
        str.getClass();
        switch (str) {
            case "USER_CANCELLED":
                i4 = 18001;
                break;
            case "INVALID_RECIPIENT_EMAIL":
                i4 = 17033;
                break;
            case "WEB_CONTEXT_ALREADY_PRESENTED":
                i4 = 17057;
                break;
            case "INTERNAL_SUCCESS_SIGN_OUT":
                i4 = 17091;
                break;
            case "INVALID_IDP_RESPONSE":
            case "INVALID_LOGIN_CREDENTIALS":
            case "INVALID_PENDING_TOKEN":
                i4 = 17004;
                break;
            case "DYNAMIC_LINK_NOT_ACTIVATED":
                i4 = 17068;
                break;
            case "QUOTA_EXCEEDED":
                i4 = 17052;
                break;
            case "WEB_NETWORK_REQUEST_FAILED":
                i4 = 17061;
                break;
            case "INVALID_RECAPTCHA_VERSION":
                i4 = 17206;
                break;
            case "RECAPTCHA_NOT_ENABLED":
                i4 = 17200;
                break;
            case "EXPIRED_OOB_CODE":
                i4 = 17029;
                break;
            case "UNAUTHORIZED_DOMAIN":
                i4 = 17038;
                break;
            case "INVALID_OOB_CODE":
                i4 = 17030;
                break;
            case "MISSING_EMAIL":
                i4 = 17034;
                break;
            case "INVALID_CODE":
                i4 = 17044;
                break;
            case "TOKEN_EXPIRED":
                i4 = 17021;
                break;
            case "INVALID_TENANT_ID":
                i4 = 17079;
                break;
            case "ALTERNATE_CLIENT_IDENTIFIER_REQUIRED":
                i4 = 18002;
                break;
            case "INVALID_SESSION_INFO":
                i4 = 17046;
                break;
            case "SECOND_FACTOR_EXISTS":
                i4 = 17087;
                break;
            case "INVALID_EMAIL":
            case "INVALID_IDENTIFIER":
                i4 = 17008;
                break;
            case "ADMIN_ONLY_OPERATION":
                i4 = 17085;
                break;
            case "MISSING_OR_INVALID_NONCE":
                i4 = 17094;
                break;
            case "INVALID_CERT_HASH":
                i4 = 17064;
                break;
            case "NO_SUCH_PROVIDER":
                i4 = 17016;
                break;
            case "MFA_ENROLLMENT_NOT_FOUND":
                i4 = 17084;
                break;
            case "MISSING_PASSWORD":
                i4 = 17035;
                break;
            case "CREDENTIAL_TOO_OLD_LOGIN_AGAIN":
                i4 = 17014;
                break;
            case "TIMEOUT":
            case "<<Network Error>>":
                i4 = 17020;
                break;
            case "INVALID_REQ_TYPE":
                i4 = 17207;
                break;
            case "INVALID_RECAPTCHA_ACTION":
                i4 = 17203;
                break;
            case "OPERATION_NOT_ALLOWED":
            case "PASSWORD_LOGIN_DISABLED":
                i4 = 17006;
                break;
            case "WEB_INTERNAL_ERROR":
                i4 = 17062;
                break;
            case "SECOND_FACTOR_LIMIT_EXCEEDED":
                i4 = 17088;
                break;
            case "MISSING_MFA_ENROLLMENT_ID":
                i4 = 17082;
                break;
            case "USER_NOT_FOUND":
            case "EMAIL_NOT_FOUND":
                i4 = 17011;
                break;
            case "CAPTCHA_CHECK_FAILED":
                i4 = 17056;
                break;
            case "WEAK_PASSWORD":
                i4 = 17026;
                break;
            case "UNSUPPORTED_FIRST_FACTOR":
                i4 = 17089;
                break;
            case "INVALID_SENDER":
                i4 = 17032;
                break;
            case "MISSING_PHONE_NUMBER":
                i4 = 17041;
                break;
            case "INVALID_DYNAMIC_LINK_DOMAIN":
                i4 = 17074;
                break;
            case "MISSING_MFA_PENDING_CREDENTIAL":
                i4 = 17081;
                break;
            case "UNSUPPORTED_PASSTHROUGH_OPERATION":
                i4 = 17095;
                break;
            case "EMAIL_EXISTS":
                i4 = 17007;
                break;
            case "INVALID_ID_TOKEN":
                i4 = 17017;
                break;
            case "WEB_STORAGE_UNSUPPORTED":
                i4 = 17065;
                break;
            case "MISSING_CLIENT_TYPE":
                i4 = 17204;
                break;
            case "MISSING_RECAPTCHA_VERSION":
                i4 = 17205;
                break;
            case "UNVERIFIED_EMAIL":
                i4 = 17086;
                break;
            case "REJECTED_CREDENTIAL":
                i4 = 17075;
                break;
            case "INVALID_MFA_PENDING_CREDENTIAL":
                i4 = 17083;
                break;
            case "INVALID_VERIFICATION_PROOF":
                i4 = 17049;
                break;
            case "INVALID_PROVIDER_ID":
                i4 = 17071;
                break;
            case "CREDENTIAL_MISMATCH":
                i4 = 17002;
                break;
            case "WEB_CONTEXT_CANCELED":
                i4 = 17058;
                break;
            case "REQUIRES_SECOND_FACTOR_AUTH":
                i4 = 17078;
                break;
            case "MISSING_CLIENT_IDENTIFIER":
                i4 = 17093;
                break;
            case "INVALID_MESSAGE_PAYLOAD":
                i4 = 17031;
                break;
            case "RESET_PASSWORD_EXCEED_LIMIT":
            case "TOO_MANY_ATTEMPTS_TRY_LATER":
                i4 = 17010;
                break;
            case "INVALID_CUSTOM_TOKEN":
                i4 = 17000;
                break;
            case "INVALID_PASSWORD":
                i4 = 17009;
                break;
            case "INVALID_RECAPTCHA_TOKEN":
                i4 = 17202;
                break;
            case "SESSION_EXPIRED":
                i4 = 17051;
                break;
            case "MISSING_CODE":
                i4 = 17043;
                break;
            case "FEDERATED_USER_ID_ALREADY_LINKED":
                i4 = 17025;
                break;
            case "MISSING_RECAPTCHA_TOKEN":
                i4 = 17201;
                break;
            case "USER_DISABLED":
                i4 = 17005;
                break;
            case "INVALID_PHONE_NUMBER":
                i4 = 17042;
                break;
            case "INVALID_APP_CREDENTIAL":
                i4 = 17028;
                break;
            case "MISSING_CONTINUE_URI":
                i4 = 17040;
                break;
            case "MISSING_SESSION_INFO":
                i4 = 17045;
                break;
            case "EMAIL_CHANGE_NEEDS_VERIFICATION":
                i4 = 17090;
                break;
            case "UNSUPPORTED_TENANT_OPERATION":
                i4 = 17073;
                break;
            default:
                i4 = 17499;
                break;
        }
        if (i4 != 17499) {
            return new Status(i4, str2);
        }
        if (str2 == null) {
            return new Status(i4, str);
        }
        return new Status(i4, str + ":" + str2);
    }

    public static final byte[] a(SecretKey secretKey, byte[] bArr, byte[] bArr2, int i4) throws NoSuchAlgorithmException, InvalidKeyException {
        J3.i.e(secretKey, "secret");
        J3.i.e(bArr, "label");
        byte[] bArrJ0 = AbstractC0726f.j0(bArr, bArr2);
        Mac mac = Mac.getInstance(secretKey.getAlgorithm());
        J3.i.d(mac, "getInstance(...)");
        if (i4 < 12) {
            throw new IllegalArgumentException("Failed requirement.");
        }
        byte[] bArrJ02 = new byte[0];
        byte[] bArrDoFinal = bArrJ0;
        while (bArrJ02.length < i4) {
            mac.reset();
            mac.init(secretKey);
            mac.update(bArrDoFinal);
            bArrDoFinal = mac.doFinal();
            J3.i.d(bArrDoFinal, "doFinal(...)");
            mac.reset();
            mac.init(secretKey);
            mac.update(bArrDoFinal);
            mac.update(bArrJ0);
            byte[] bArrDoFinal2 = mac.doFinal();
            J3.i.d(bArrDoFinal2, "doFinal(...)");
            bArrJ02 = AbstractC0726f.j0(bArrJ02, bArrDoFinal2);
        }
        byte[] bArrCopyOf = Arrays.copyOf(bArrJ02, i4);
        J3.i.d(bArrCopyOf, "copyOf(...)");
        return bArrCopyOf;
    }

    public static void b(Throwable th, Throwable th2) throws IllegalAccessException, InvocationTargetException {
        J3.i.e(th, "<this>");
        J3.i.e(th2, "exception");
        if (th != th2) {
            Integer num = D3.a.f277a;
            if (num == null || num.intValue() >= 19) {
                th.addSuppressed(th2);
                return;
            }
            Method method = C3.a.f130a;
            if (method != null) {
                method.invoke(th, th2);
            }
        }
    }

    public static void c(Context context, InterfaceC0555b interfaceC0555b) throws Exception {
        Rect rect;
        X xB;
        Activity activityR = r(context);
        if (activityR != null) {
            i0.l.f4485a.getClass();
            int i4 = i0.n.f4486b;
            int i5 = Build.VERSION.SDK_INT;
            if (i5 >= 30) {
                rect = ((WindowManager) activityR.getSystemService(WindowManager.class)).getMaximumWindowMetrics().getBounds();
                J3.i.d(rect, "wm.maximumWindowMetrics.bounds");
            } else {
                Object systemService = activityR.getSystemService("window");
                J3.i.c(systemService, "null cannot be cast to non-null type android.view.WindowManager");
                Display defaultDisplay = ((WindowManager) systemService).getDefaultDisplay();
                J3.i.d(defaultDisplay, "display");
                Point point = new Point();
                defaultDisplay.getRealSize(point);
                rect = new Rect(0, 0, point.x, point.y);
            }
            if (i5 < 30) {
                xB = (i5 >= 30 ? new M() : i5 >= 29 ? new L() : new J()).b();
                J3.i.d(xB, "{\n            WindowInse…ilder().build()\n        }");
            } else {
                if (i5 < 30) {
                    throw new Exception("Incompatible SDK version");
                }
                xB = C0545a.f5762a.a(activityR);
            }
            int i6 = rect.left;
            int i7 = rect.top;
            int i8 = rect.right;
            int i9 = rect.bottom;
            if (i6 > i8) {
                throw new IllegalArgumentException(B1.a.k("Left must be less than or equal to right, left: ", i6, i8, ", right: ").toString());
            }
            if (i7 > i9) {
                throw new IllegalArgumentException(B1.a.k("top must be less than or equal to bottom, top: ", i7, i9, ", bottom: ").toString());
            }
            J3.i.e(xB, "_windowInsetsCompat");
            ((E2.c) interfaceC0555b).f341a.updateDisplayMetrics(0, new Rect(i6, i7, i8, i9).width(), new Rect(i6, i7, i8, i9).height(), context.getResources().getDisplayMetrics().density);
        }
    }

    public static void g(int i4, int i5, int i6) {
        if (i4 >= 0 && i5 <= i6) {
            if (i4 > i5) {
                throw new IllegalArgumentException(B1.a.k("fromIndex: ", i4, i5, " > toIndex: "));
            }
            return;
        }
        throw new IndexOutOfBoundsException("fromIndex: " + i4 + ", toIndex: " + i5 + ", size: " + i6);
    }

    public static final void h(int i4, int i5) {
        String strL;
        if (i4 <= 0 || i5 <= 0) {
            if (i4 != i5) {
                strL = "Both size " + i4 + " and step " + i5 + " must be greater than zero.";
            } else {
                strL = B1.a.l("size ", i4, " must be greater than zero.");
            }
            throw new IllegalArgumentException(strL.toString());
        }
    }

    public static void i(Closeable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (IOException unused) {
            }
        }
    }

    public static boolean j(File file, Resources resources, int i4) throws Throwable {
        InputStream inputStreamOpenRawResource;
        try {
            inputStreamOpenRawResource = resources.openRawResource(i4);
            try {
                boolean zK = k(file, inputStreamOpenRawResource);
                i(inputStreamOpenRawResource);
                return zK;
            } catch (Throwable th) {
                th = th;
                i(inputStreamOpenRawResource);
                throw th;
            }
        } catch (Throwable th2) {
            th = th2;
            inputStreamOpenRawResource = null;
        }
    }

    public static boolean k(File file, InputStream inputStream) throws Throwable {
        FileOutputStream fileOutputStream;
        StrictMode.ThreadPolicy threadPolicyAllowThreadDiskWrites = StrictMode.allowThreadDiskWrites();
        FileOutputStream fileOutputStream2 = null;
        try {
            try {
                fileOutputStream = new FileOutputStream(file, false);
            } catch (IOException e) {
                e = e;
            }
        } catch (Throwable th) {
            th = th;
        }
        try {
            byte[] bArr = new byte[1024];
            while (true) {
                int i4 = inputStream.read(bArr);
                if (i4 == -1) {
                    i(fileOutputStream);
                    StrictMode.setThreadPolicy(threadPolicyAllowThreadDiskWrites);
                    return true;
                }
                fileOutputStream.write(bArr, 0, i4);
            }
        } catch (IOException e4) {
            e = e4;
            fileOutputStream2 = fileOutputStream;
            Log.e("TypefaceCompatUtil", "Error copying resource contents to temp file: " + e.getMessage());
            i(fileOutputStream2);
            StrictMode.setThreadPolicy(threadPolicyAllowThreadDiskWrites);
            return false;
        } catch (Throwable th2) {
            th = th2;
            fileOutputStream2 = fileOutputStream;
            i(fileOutputStream2);
            StrictMode.setThreadPolicy(threadPolicyAllowThreadDiskWrites);
            throw th;
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    public static InterfaceC0762c l(I3.p pVar, InterfaceC0762c interfaceC0762c, InterfaceC0762c interfaceC0762c2) {
        J3.i.e(pVar, "<this>");
        if (pVar instanceof A3.a) {
            return ((A3.a) pVar).create(interfaceC0762c, interfaceC0762c2);
        }
        InterfaceC0767h context = interfaceC0762c2.getContext();
        return context == C0768i.f6945a ? new C0790b(pVar, interfaceC0762c2, interfaceC0762c) : new C0791c(interfaceC0762c2, context, pVar, interfaceC0762c);
    }

    public static byte[] m(String str) {
        if (str.length() % 2 != 0) {
            throw new IllegalArgumentException("Expected a string of even length");
        }
        int length = str.length() / 2;
        byte[] bArr = new byte[length];
        for (int i4 = 0; i4 < length; i4++) {
            int i5 = i4 * 2;
            int iDigit = Character.digit(str.charAt(i5), 16);
            int iDigit2 = Character.digit(str.charAt(i5 + 1), 16);
            if (iDigit == -1 || iDigit2 == -1) {
                throw new IllegalArgumentException("input is not hexadecimal");
            }
            bArr[i4] = (byte) ((iDigit * 16) + iDigit2);
        }
        return bArr;
    }

    public static boolean n(Object obj, Object obj2) {
        if ((obj instanceof byte[]) && (obj2 instanceof byte[])) {
            return Arrays.equals((byte[]) obj, (byte[]) obj2);
        }
        if ((obj instanceof int[]) && (obj2 instanceof int[])) {
            return Arrays.equals((int[]) obj, (int[]) obj2);
        }
        if ((obj instanceof long[]) && (obj2 instanceof long[])) {
            return Arrays.equals((long[]) obj, (long[]) obj2);
        }
        if ((obj instanceof double[]) && (obj2 instanceof double[])) {
            return Arrays.equals((double[]) obj, (double[]) obj2);
        }
        if ((obj instanceof Object[]) && (obj2 instanceof Object[])) {
            Object[] objArr = (Object[]) obj;
            Object[] objArr2 = (Object[]) obj2;
            if (objArr.length == objArr2.length) {
                Iterable fVar = new M3.f(0, objArr.length - 1, 1);
                if (!(fVar instanceof Collection) || !((Collection) fVar).isEmpty()) {
                    Iterator it = fVar.iterator();
                    while (((M3.e) it).f1100c) {
                        int iA = ((M3.e) it).a();
                        if (!n(objArr[iA], objArr2[iA])) {
                        }
                    }
                }
                return true;
            }
            return false;
        }
        if ((obj instanceof List) && (obj2 instanceof List)) {
            List list = (List) obj;
            List list2 = (List) obj2;
            if (list.size() == list2.size()) {
                Collection collection = (Collection) obj;
                J3.i.e(collection, "<this>");
                Iterable fVar2 = new M3.f(0, collection.size() - 1, 1);
                if (!(fVar2 instanceof Collection) || !((Collection) fVar2).isEmpty()) {
                    Iterator it2 = fVar2.iterator();
                    while (((M3.e) it2).f1100c) {
                        int iA2 = ((M3.e) it2).a();
                        if (!n(list.get(iA2), list2.get(iA2))) {
                        }
                    }
                }
                return true;
            }
            return false;
        }
        if (!(obj instanceof Map) || !(obj2 instanceof Map)) {
            return J3.i.a(obj, obj2);
        }
        Map map = (Map) obj;
        Map map2 = (Map) obj2;
        if (map.size() == map2.size()) {
            if (!map.isEmpty()) {
                for (Map.Entry entry : map.entrySet()) {
                    if (!map2.containsKey(entry.getKey()) || !n(entry.getValue(), map2.get(entry.getKey()))) {
                    }
                }
            }
            return true;
        }
        return false;
    }

    public static void o(ArrayList arrayList) {
        HashMap map = new HashMap(arrayList.size());
        Iterator it = arrayList.iterator();
        while (true) {
            int i4 = 0;
            if (!it.hasNext()) {
                Iterator it2 = map.values().iterator();
                while (it2.hasNext()) {
                    for (l1.h hVar : (Set) it2.next()) {
                        for (l1.j jVar : hVar.f5606a.f5590b) {
                            if (jVar.f5613c == 0) {
                                Set<l1.h> set = (Set) map.get(new l1.i(jVar.f5611a, jVar.f5612b == 2));
                                if (set != null) {
                                    for (l1.h hVar2 : set) {
                                        hVar.f5607b.add(hVar2);
                                        hVar2.f5608c.add(hVar);
                                    }
                                }
                            }
                        }
                    }
                }
                HashSet<l1.h> hashSet = new HashSet();
                Iterator it3 = map.values().iterator();
                while (it3.hasNext()) {
                    hashSet.addAll((Set) it3.next());
                }
                HashSet hashSet2 = new HashSet();
                for (l1.h hVar3 : hashSet) {
                    if (hVar3.f5608c.isEmpty()) {
                        hashSet2.add(hVar3);
                    }
                }
                while (!hashSet2.isEmpty()) {
                    l1.h hVar4 = (l1.h) hashSet2.iterator().next();
                    hashSet2.remove(hVar4);
                    i4++;
                    for (l1.h hVar5 : hVar4.f5607b) {
                        hVar5.f5608c.remove(hVar4);
                        if (hVar5.f5608c.isEmpty()) {
                            hashSet2.add(hVar5);
                        }
                    }
                }
                if (i4 == arrayList.size()) {
                    return;
                }
                ArrayList arrayList2 = new ArrayList();
                for (l1.h hVar6 : hashSet) {
                    if (!hVar6.f5608c.isEmpty() && !hVar6.f5607b.isEmpty()) {
                        arrayList2.add(hVar6.f5606a);
                    }
                }
                throw new l1.k("Dependency cycle detected: " + Arrays.toString(arrayList2.toArray()));
            }
            C0522a c0522a = (C0522a) it.next();
            l1.h hVar7 = new l1.h(c0522a);
            for (r rVar : c0522a.f5589a) {
                boolean z4 = c0522a.f5591c == 0;
                l1.i iVar = new l1.i(rVar, !z4);
                if (!map.containsKey(iVar)) {
                    map.put(iVar, new HashSet());
                }
                Set set2 = (Set) map.get(iVar);
                if (!set2.isEmpty() && z4) {
                    throw new IllegalArgumentException("Multiple components provide " + rVar + ".");
                }
                set2.add(hVar7);
            }
        }
    }

    public static String p(byte[] bArr) {
        StringBuilder sb = new StringBuilder(bArr.length * 2);
        for (byte b5 : bArr) {
            int i4 = b5 & 255;
            sb.append("0123456789abcdef".charAt(i4 / 16));
            sb.append("0123456789abcdef".charAt(i4 % 16));
        }
        return sb.toString();
    }

    public static String q(String str, String str2) {
        for (String str3 : (String[]) P3.m.D0(str2, new String[]{"&"}).toArray(new String[0])) {
            if (P3.m.q0(str3, str, false)) {
                String strSubstring = str3.substring(str.length());
                J3.i.d(strSubstring, "substring(...)");
                return strSubstring;
            }
        }
        return "";
    }

    public static Activity r(Context context) {
        if (context == null) {
            return null;
        }
        if (context instanceof Activity) {
            return (Activity) context;
        }
        if (context instanceof ContextWrapper) {
            return r(((ContextWrapper) context).getBaseContext());
        }
        return null;
    }

    public static String s(String str, String str2, String str3, String str4, String str5) {
        String str6 = String.format("%08x", Arrays.copyOf(new Object[]{Integer.valueOf(new Random().nextInt())}, 1));
        String strE = E(str + str3 + str2);
        if (str5.length() > 0) {
            strE = strE.concat(str5);
        } else if (str4.length() > 0) {
            strE = strE.concat(str4);
        }
        String str7 = "?authmod=adobe&user=" + str + "&challenge=" + str6 + "&response=" + E(strE + str6);
        if (str5.length() <= 0) {
            return str7;
        }
        return str7 + "&opaque=" + str5;
    }

    public static String t(String str, String str2, String str3, String str4) {
        J3.i.e(str4, "app");
        String str5 = String.format("%08x", Arrays.copyOf(new Object[]{1}, 1));
        String str6 = String.format("%08x", Arrays.copyOf(new Object[]{Integer.valueOf(new Random().nextInt())}, 1));
        int iU0 = P3.m.u0(0, 6, str4, "?", false);
        if (iU0 >= 0) {
            str4 = str4.substring(0, iU0);
            J3.i.d(str4, "substring(...)");
        }
        if (!P3.m.q0(str4, "/", false)) {
            str4 = str4.concat("/_definst_");
        }
        String strD = AbstractC0752b.d(str + ":live:" + str2);
        StringBuilder sb = new StringBuilder("publish:/");
        sb.append(str4);
        return "?authmod=llnw&user=" + str + "&nonce=" + str3 + "&cnonce=" + str6 + "&nc=" + str5 + "&response=" + AbstractC0752b.d(strD + ":" + str3 + ":" + str5 + ":" + str6 + ":auth:" + AbstractC0752b.d(sb.toString()));
    }

    public static Q.b u(byte[] bArr) throws IOException {
        Object obj;
        Object next;
        C0592H c0592h = s2.c.f6489b;
        int i4 = (bArr[0] >>> 7) & 1;
        c0592h.getClass();
        int iOrdinal = C0592H.d(i4).ordinal();
        if (iOrdinal == 0) {
            return new s2.b(0, 0, 0, 0, null, 511);
        }
        if (iOrdinal != 1) {
            throw new A0.b();
        }
        int iH = AbstractC0752b.h(new ByteArrayInputStream(AbstractC0726f.k0(bArr, AbstractC0184a.Z(0, 4))));
        EnumC0679d.f6570b.getClass();
        EnumC0679d enumC0679dE = C0592H.e((iH >>> 16) & 255);
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bArr);
        switch (enumC0679dE.ordinal()) {
            case 0:
                u2.c cVar = new u2.c();
                cVar.k(byteArrayInputStream);
                cVar.f6649g = AbstractC0752b.h(byteArrayInputStream);
                C0592H c0592h2 = EnumC0691a.f6643b;
                int iG = AbstractC0752b.g(byteArrayInputStream);
                c0592h2.getClass();
                Iterator it = EnumC0691a.e.iterator();
                while (true) {
                    obj = null;
                    if (it.hasNext()) {
                        next = it.next();
                        if (((EnumC0691a) next).f6646a == iG) {
                        }
                    } else {
                        next = null;
                    }
                }
                EnumC0691a enumC0691a = (EnumC0691a) next;
                if (enumC0691a == null) {
                    throw new IOException(S.d(iG, "unknown encryption: "));
                }
                cVar.f6650h = enumC0691a;
                cVar.f6651i = AbstractC0752b.g(byteArrayInputStream);
                cVar.f6652j = AbstractC0752b.h(byteArrayInputStream) & com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
                cVar.f6653k = AbstractC0752b.h(byteArrayInputStream);
                cVar.f6654l = AbstractC0752b.h(byteArrayInputStream);
                C0592H c0592h3 = u2.d.f6660b;
                int iH2 = AbstractC0752b.h(byteArrayInputStream);
                c0592h3.getClass();
                Iterator it2 = u2.d.f6663f.iterator();
                while (true) {
                    if (it2.hasNext()) {
                        Object next2 = it2.next();
                        if (((u2.d) next2).f6664a == iH2) {
                            obj = next2;
                        }
                    }
                }
                u2.d dVar = (u2.d) obj;
                if (dVar == null) {
                    throw new IOException(S.d(iH2, "unknown handshake type: "));
                }
                cVar.f6655m = dVar;
                cVar.f6656n = AbstractC0752b.h(byteArrayInputStream);
                cVar.f6657o = AbstractC0752b.h(byteArrayInputStream);
                AbstractC0752b.h(byteArrayInputStream);
                AbstractC0752b.h(byteArrayInputStream);
                AbstractC0752b.h(byteArrayInputStream);
                AbstractC0752b.h(byteArrayInputStream);
                return cVar;
            case 1:
                C0681f c0681f = new C0681f(EnumC0679d.f6572d, 30);
                c0681f.k(byteArrayInputStream);
                AbstractC0752b.h(byteArrayInputStream);
                return c0681f;
            case 2:
                C0677b c0677b = new C0677b(EnumC0679d.e, 30);
                c0677b.f6563g = 0;
                c0677b.f6564h = 0;
                c0677b.f6565i = 0;
                c0677b.f6566j = 0;
                c0677b.f6567k = 0;
                c0677b.f6568l = 0;
                c0677b.f6569m = 0;
                c0677b.k(byteArrayInputStream);
                c0677b.f6563g = AbstractC0752b.h(byteArrayInputStream) & com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
                c0677b.f6564h = AbstractC0752b.h(byteArrayInputStream);
                c0677b.f6565i = AbstractC0752b.h(byteArrayInputStream);
                c0677b.f6566j = AbstractC0752b.h(byteArrayInputStream);
                c0677b.f6567k = AbstractC0752b.h(byteArrayInputStream);
                c0677b.f6568l = AbstractC0752b.h(byteArrayInputStream);
                c0677b.f6569m = AbstractC0752b.h(byteArrayInputStream);
                return c0677b;
            case 3:
                C0682g c0682g = new C0682g();
                c0682g.k(byteArrayInputStream);
                while (true) {
                    boolean z4 = false;
                    while (byteArrayInputStream.available() >= 4) {
                        int iH3 = AbstractC0752b.h(byteArrayInputStream);
                        int i5 = (iH3 >> 31) & 1;
                        ArrayList arrayList = c0682g.f6586g;
                        if (i5 == 0) {
                            arrayList.add(Integer.valueOf(iH3));
                            if (!z4) {
                                arrayList.add(Integer.valueOf(iH3));
                            }
                        } else {
                            arrayList.add(Integer.valueOf(iH3));
                            z4 = true;
                        }
                    }
                    return c0682g;
                }
            case 4:
                C0678c c0678c = new C0678c(EnumC0679d.f6574m, 30);
                c0678c.k(byteArrayInputStream);
                AbstractC0752b.h(byteArrayInputStream);
                return c0678c;
            case 5:
                C0684i c0684i = new C0684i(EnumC0679d.f6575n, 30);
                c0684i.k(byteArrayInputStream);
                AbstractC0752b.h(byteArrayInputStream);
                return c0684i;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                C0676a c0676a = new C0676a(EnumC0679d.f6576o, 26);
                c0676a.f6562g = 0;
                c0676a.k(byteArrayInputStream);
                c0676a.f6562g = c0676a.f6480d;
                AbstractC0752b.h(byteArrayInputStream);
                return c0676a;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                C0680e c0680e = new C0680e(EnumC0679d.f6577p, 26);
                c0680e.f6583g = 0;
                c0680e.f6584h = 0;
                c0680e.f6585i = 0;
                c0680e.k(byteArrayInputStream);
                c0680e.f6583g = c0680e.f6480d;
                c0680e.f6584h = AbstractC0752b.h(byteArrayInputStream) & com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
                c0680e.f6585i = AbstractC0752b.h(byteArrayInputStream) & com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
                return c0680e;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                C0683h c0683h = new C0683h(EnumC0679d.f6578q, 26);
                c0683h.f6587g = 0;
                c0683h.k(byteArrayInputStream);
                c0683h.f6587g = c0683h.f6480d;
                AbstractC0752b.h(byteArrayInputStream);
                return c0683h;
            case 9:
                throw new IOException("user defined type is not allowed");
            default:
                throw new IOException(B1.a.m("unknown control type: ", enumC0679dE.name()));
        }
    }

    public static File v(Context context) {
        File cacheDir = context.getCacheDir();
        if (cacheDir == null) {
            return null;
        }
        String str = ".font" + Process.myPid() + "-" + Process.myTid() + "-";
        for (int i4 = 0; i4 < 100; i4++) {
            File file = new File(cacheDir, str + i4);
            if (file.createNewFile()) {
                return file;
            }
        }
        return null;
    }

    public static InterfaceC0762c w(InterfaceC0762c interfaceC0762c) {
        InterfaceC0762c interfaceC0762cIntercepted;
        J3.i.e(interfaceC0762c, "<this>");
        A3.c cVar = interfaceC0762c instanceof A3.c ? (A3.c) interfaceC0762c : null;
        return (cVar == null || (interfaceC0762cIntercepted = cVar.intercepted()) == null) ? interfaceC0762c : interfaceC0762cIntercepted;
    }

    public static List x(Object obj) {
        List listSingletonList = Collections.singletonList(obj);
        J3.i.d(listSingletonList, "singletonList(...)");
        return listSingletonList;
    }

    public static MappedByteBuffer y(Context context, Uri uri) {
        ParcelFileDescriptor parcelFileDescriptorOpenFileDescriptor;
        try {
            parcelFileDescriptorOpenFileDescriptor = context.getContentResolver().openFileDescriptor(uri, "r", null);
        } catch (IOException unused) {
        }
        if (parcelFileDescriptorOpenFileDescriptor == null) {
            if (parcelFileDescriptorOpenFileDescriptor != null) {
                parcelFileDescriptorOpenFileDescriptor.close();
                return null;
            }
            return null;
        }
        try {
            FileInputStream fileInputStream = new FileInputStream(parcelFileDescriptorOpenFileDescriptor.getFileDescriptor());
            try {
                FileChannel channel = fileInputStream.getChannel();
                MappedByteBuffer map = channel.map(FileChannel.MapMode.READ_ONLY, 0L, channel.size());
                fileInputStream.close();
                parcelFileDescriptorOpenFileDescriptor.close();
                return map;
            } finally {
            }
        } finally {
        }
    }

    public static f0.h z(String str) {
        String strGroup;
        if (str == null || P3.m.v0(str)) {
            return null;
        }
        Matcher matcher = Pattern.compile("(\\d+)(?:\\.(\\d+))(?:\\.(\\d+))(?:-(.+))?").matcher(str);
        if (!matcher.matches() || (strGroup = matcher.group(1)) == null) {
            return null;
        }
        int i4 = Integer.parseInt(strGroup);
        String strGroup2 = matcher.group(2);
        if (strGroup2 == null) {
            return null;
        }
        int i5 = Integer.parseInt(strGroup2);
        String strGroup3 = matcher.group(3);
        if (strGroup3 == null) {
            return null;
        }
        int i6 = Integer.parseInt(strGroup3);
        String strGroup4 = matcher.group(4) != null ? matcher.group(4) : "";
        J3.i.d(strGroup4, "description");
        return new f0.h(i4, i5, i6, strGroup4);
    }

    public abstract void B(C0575g c0575g, C0575g c0575g2);

    public abstract void C(C0575g c0575g, Thread thread);

    public Task Q(FirebaseAuth firebaseAuth, String str, RecaptchaAction recaptchaAction) {
        R0.k kVar;
        zzafj zzafjVar;
        B.k kVar2 = new B.k(25, false);
        kVar2.f104b = this;
        synchronized (firebaseAuth) {
            kVar = firebaseAuth.f3849j;
        }
        if (kVar != null && (zzafjVar = (zzafj) kVar.f1692c) != null && zzafjVar.zzb("EMAIL_PASSWORD_PROVIDER")) {
            return kVar.j(str, Boolean.FALSE, recaptchaAction).continueWithTask(kVar2).continueWithTask(new C0053n(str, kVar, recaptchaAction, kVar2, 12));
        }
        Task taskR = R(null);
        C0053n c0053n = new C0053n(11, false);
        c0053n.f706b = recaptchaAction;
        c0053n.f707c = firebaseAuth;
        c0053n.f708d = str;
        c0053n.e = kVar2;
        return taskR.continueWithTask(c0053n);
    }

    public abstract Task R(String str);

    public abstract boolean d(AbstractFutureC0576h abstractFutureC0576h, C0572d c0572d);

    public abstract boolean e(AbstractFutureC0576h abstractFutureC0576h, Object obj, Object obj2);

    public abstract boolean f(AbstractFutureC0576h abstractFutureC0576h, C0575g c0575g, C0575g c0575g2);
}
