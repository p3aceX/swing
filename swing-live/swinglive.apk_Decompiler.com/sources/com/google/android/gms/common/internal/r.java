package com.google.android.gms.common.internal;

import D2.AbstractActivityC0029d;
import Q3.x0;
import android.app.Application;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.provider.Settings;
import android.security.keystore.KeyGenParameterSpec;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import android.util.SparseIntArray;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.auth.zze;
import com.google.android.gms.internal.p002firebaseauthapi.zzac;
import com.google.android.gms.internal.p002firebaseauthapi.zzacl;
import com.google.android.gms.internal.p002firebaseauthapi.zzafj;
import com.google.android.gms.internal.p002firebaseauthapi.zzafm;
import com.google.android.gms.internal.p002firebaseauthapi.zzah;
import com.google.android.gms.internal.p002firebaseauthapi.zzxv;
import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.android.recaptcha.Recaptcha;
import com.google.android.recaptcha.RecaptchaTasksClient;
import com.google.firebase.auth.internal.GenericIdpActivity;
import com.google.firebase.auth.internal.RecaptchaActivity;
import com.swing.live.R;
import e1.AbstractC0367g;
import f.AbstractC0398a;
import g.AbstractC0404a;
import io.ktor.utils.io.C0449m;
import java.io.IOException;
import java.math.BigInteger;
import java.security.Key;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.cert.CertificateException;
import java.security.spec.AlgorithmParameterSpec;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.concurrent.locks.ReentrantLock;
import javax.crypto.Cipher;
import javax.security.auth.x500.X500Principal;
import k.AbstractC0508z;
import k.C0498o;
import l3.C0523A;
import o0.C0579b;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import q0.AbstractC0630d;
import q0.InterfaceC0633g;
import u1.C0690c;
import x.C0708e;
import y0.C0747k;
import z0.C0774e;

/* JADX INFO: loaded from: classes.dex */
public class r implements i0.h, io.flutter.plugin.platform.j, N2.i, io.ktor.utils.io.v, OnCompleteListener, Continuation, O2.m, InterfaceC0633g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3596a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f3597b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f3598c;

    public /* synthetic */ r(int i4, Object obj, Object obj2) {
        this.f3596a = i4;
        this.f3597b = obj;
        this.f3598c = obj2;
    }

    public String A(String str) {
        Resources resources = (Resources) this.f3597b;
        int identifier = resources.getIdentifier(str, "string", (String) this.f3598c);
        if (identifier == 0) {
            return null;
        }
        return resources.getString(identifier);
    }

    public void B(int i4) {
        int resourceId;
        ImageView imageView = (ImageView) this.f3597b;
        C0747k c0747kP = C0747k.P(imageView.getContext(), null, AbstractC0398a.e, i4);
        try {
            Drawable drawable = imageView.getDrawable();
            TypedArray typedArray = (TypedArray) c0747kP.f6832c;
            if (drawable == null && (resourceId = typedArray.getResourceId(1, -1)) != -1 && (drawable = AbstractC0404a.a(imageView.getContext(), resourceId)) != null) {
                imageView.setImageDrawable(drawable);
            }
            if (drawable != null) {
                Rect rect = AbstractC0508z.f5489a;
            }
            if (typedArray.hasValue(2)) {
                F.f.c(imageView, c0747kP.E(2));
            }
            if (typedArray.hasValue(3)) {
                F.f.d(imageView, AbstractC0508z.c(typedArray.getInt(3, -1), null));
            }
            c0747kP.T();
        } catch (Throwable th) {
            c0747kP.T();
            throw th;
        }
    }

    public KeyGenParameterSpec C(Calendar calendar, Calendar calendar2) {
        String str = (String) this.f3597b;
        return new KeyGenParameterSpec.Builder(str, 3).setCertificateSubject(new X500Principal(B1.a.m("CN=", str))).setDigests("SHA-256").setBlockModes("ECB").setEncryptionPaddings("PKCS1Padding").setCertificateSerialNumber(BigInteger.valueOf(1L)).setCertificateNotBefore(calendar.getTime()).setCertificateNotAfter(calendar2.getTime()).build();
    }

    public void D(C0708e c0708e) {
        int i4 = c0708e.f6738b;
        Handler handler = (Handler) this.f3598c;
        C0523A c0523a = (C0523A) this.f3597b;
        if (i4 != 0) {
            handler.post(new F.b(c0523a, i4));
        } else {
            handler.post(new x0(7, c0523a, c0708e.f6737a));
        }
    }

    public void E(Locale locale) {
        Locale.setDefault(locale);
        Context context = (Context) this.f3598c;
        Configuration configuration = context.getResources().getConfiguration();
        configuration.setLocale(locale);
        context.createConfigurationContext(configuration);
    }

    public void F(int i4, String str) {
        J3.i.e(str, "name");
        ((HashMap) this.f3597b).put(Integer.valueOf(i4), str);
    }

    public Key G(byte[] bArr) throws Exception {
        KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
        keyStore.load(null);
        String str = (String) this.f3597b;
        Key key = keyStore.getKey(str, null);
        if (key == null) {
            throw new Exception(B1.a.m("No key found under alias: ", str));
        }
        if (!(key instanceof PrivateKey)) {
            throw new Exception("Not an instance of a PrivateKey");
        }
        Cipher cipherZ = z();
        cipherZ.init(4, (PrivateKey) key, y());
        return cipherZ.unwrap(bArr, "AES", 3);
    }

    public k1.e H(JSONObject jSONObject) {
        JSONArray jSONArray;
        k1.f fVarA;
        try {
            String string = jSONObject.getString("cachedTokenState");
            String string2 = jSONObject.getString("applicationName");
            boolean z4 = jSONObject.getBoolean("anonymous");
            String string3 = jSONObject.getString("version");
            String str = string3 != null ? string3 : "2";
            JSONArray jSONArray2 = jSONObject.getJSONArray("userInfos");
            int length = jSONArray2.length();
            if (length != 0) {
                ArrayList arrayList = new ArrayList(length);
                for (int i4 = 0; i4 < length; i4++) {
                    arrayList.add(k1.c.b(jSONArray2.getString(i4)));
                }
                k1.e eVar = new k1.e(g1.f.d(string2), arrayList);
                if (!TextUtils.isEmpty(string)) {
                    zzafm zzafmVarZzb = zzafm.zzb(string);
                    F.g(zzafmVarZzb);
                    eVar.f5512a = zzafmVarZzb;
                }
                if (!z4) {
                    eVar.f5518n = Boolean.FALSE;
                }
                eVar.f5517m = str;
                if (jSONObject.has("userMetadata") && (fVarA = k1.f.a(jSONObject.getJSONObject("userMetadata"))) != null) {
                    eVar.f5519o = fVarA;
                }
                if (jSONObject.has("userMultiFactorInfo") && (jSONArray = jSONObject.getJSONArray("userMultiFactorInfo")) != null) {
                    ArrayList arrayList2 = new ArrayList();
                    for (int i5 = 0; i5 < jSONArray.length(); i5++) {
                        JSONObject jSONObject2 = new JSONObject(jSONArray.getString(i5));
                        String strOptString = jSONObject2.optString("factorIdKey");
                        arrayList2.add("phone".equals(strOptString) ? j1.u.d(jSONObject2) : Objects.equals(strOptString, "totp") ? j1.x.d(jSONObject2) : null);
                    }
                    eVar.e(arrayList2);
                }
                return eVar;
            }
        } catch (zzxv e) {
            e = e;
            Log.wtf(((C0.a) this.f3598c).f120a, e);
        } catch (ArrayIndexOutOfBoundsException e4) {
            e = e4;
            Log.wtf(((C0.a) this.f3598c).f120a, e);
        } catch (IllegalArgumentException e5) {
            e = e5;
            Log.wtf(((C0.a) this.f3598c).f120a, e);
        } catch (JSONException e6) {
            e = e6;
            Log.wtf(((C0.a) this.f3598c).f120a, e);
        }
        return null;
    }

    @Override // N2.i
    public void a(int i4) {
        io.flutter.plugin.platform.p pVar = (io.flutter.plugin.platform.p) this.f3598c;
        if (pVar.s(i4) != null) {
            pVar.v.a(i4);
        } else {
            ((io.flutter.plugin.platform.q) this.f3597b).f4665C.a(i4);
        }
    }

    @Override // q0.InterfaceC0633g
    public Object b(IBinder iBinder) throws IOException, B2.a {
        Bundle bundleZzd = zze.zzb(iBinder).zzd((String) this.f3597b, (Bundle) this.f3598c);
        if (bundleZzd == null) {
            AbstractC0630d.f6254c.f("Service call returned null.", new Object[0]);
            throw new IOException("Service unavailable.");
        }
        String string = bundleZzd.getString("Error");
        if (bundleZzd.getBoolean("booleanResult")) {
            return null;
        }
        throw new B2.a(string);
    }

    @Override // N2.i
    public void c(N2.e eVar) {
        ((io.flutter.plugin.platform.q) this.f3597b).f4665C.c(eVar);
    }

    @Override // io.flutter.plugin.platform.j
    public void d() {
        ((io.flutter.plugin.platform.q) this.f3597b).d();
        ((io.flutter.plugin.platform.p) this.f3598c).d();
    }

    @Override // N2.i
    public void e(boolean z4) {
        ((io.flutter.plugin.platform.q) ((io.flutter.plugin.platform.q) this.f3597b).f4665C.f4647b).f4681x = z4;
    }

    @Override // io.flutter.plugin.platform.j
    public void f(io.flutter.view.k kVar) {
        ((io.flutter.plugin.platform.q) this.f3597b).f4673o.f4616a = kVar;
        ((io.flutter.plugin.platform.p) this.f3598c).f4654n.f4616a = kVar;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r8v16 */
    /* JADX WARN: Type inference failed for: r8v17 */
    /* JADX WARN: Type inference failed for: r8v18 */
    /* JADX WARN: Type inference failed for: r8v2 */
    /* JADX WARN: Type inference failed for: r8v3 */
    /* JADX WARN: Type inference failed for: r8v4, types: [int] */
    @Override // O2.m
    public void g(D2.v vVar, N2.j jVar) {
        Context context;
        C0579b c0579b;
        Object obj;
        String str = (String) vVar.f260b;
        str.getClass();
        context = (Context) this.f3597b;
        c0579b = (C0579b) this.f3598c;
        obj = vVar.f261c;
        switch (str) {
            case "checkServiceStatus":
                int i4 = Integer.parseInt(obj.toString());
                if (context != null) {
                    if (i4 == 3 || i4 == 4 || i4 == 5) {
                        ?? IsLocationEnabled = 0;
                        IsLocationEnabled = 0;
                        IsLocationEnabled = 0;
                        if (Build.VERSION.SDK_INT >= 28) {
                            LocationManager locationManager = (LocationManager) context.getSystemService(LocationManager.class);
                            if (locationManager != null) {
                                IsLocationEnabled = locationManager.isLocationEnabled();
                            }
                        } else {
                            try {
                                if (Settings.Secure.getInt(context.getContentResolver(), "location_mode") != 0) {
                                    IsLocationEnabled = 1;
                                }
                            } catch (Settings.SettingNotFoundException e) {
                                e.printStackTrace();
                            }
                        }
                        jVar.c(Integer.valueOf((int) IsLocationEnabled));
                    } else if (i4 == 21) {
                        jVar.c(Integer.valueOf(((BluetoothManager) context.getSystemService("bluetooth")).getAdapter().isEnabled() ? 1 : 0));
                    } else if (i4 == 8) {
                        PackageManager packageManager = context.getPackageManager();
                        if (packageManager.hasSystemFeature("android.hardware.telephony")) {
                            TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService("phone");
                            if (telephonyManager == null || telephonyManager.getPhoneType() == 0) {
                                jVar.c(2);
                            } else {
                                Intent intent = new Intent("android.intent.action.CALL");
                                intent.setData(Uri.parse("tel:123123"));
                                if ((Build.VERSION.SDK_INT >= 33 ? packageManager.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0L)) : packageManager.queryIntentActivities(intent, 0)).isEmpty()) {
                                    jVar.c(2);
                                } else if (telephonyManager.getSimState() != 5) {
                                    jVar.c(0);
                                } else {
                                    jVar.c(1);
                                }
                            }
                        } else {
                            jVar.c(2);
                        }
                    } else if (i4 == 16) {
                        jVar.c(1);
                    } else {
                        jVar.c(2);
                    }
                    break;
                } else {
                    Log.d("permissions_handler", "Context cannot be null.");
                    jVar.a(null, "PermissionHandler.ServiceManager", "Android context cannot be null.");
                    break;
                }
                break;
            case "shouldShowRequestPermissionRationale":
                int i5 = Integer.parseInt(obj.toString());
                AbstractActivityC0029d abstractActivityC0029d = c0579b.f5962c;
                if (abstractActivityC0029d != null) {
                    ArrayList arrayListV = AbstractC0367g.v(abstractActivityC0029d, i5);
                    if (arrayListV == null) {
                        Log.d("permissions_handler", "No android specific permissions needed for: " + i5);
                        jVar.c(Boolean.FALSE);
                    } else if (arrayListV.isEmpty()) {
                        Log.d("permissions_handler", "No permissions found in manifest for: " + i5 + " no need to show request rationale");
                        jVar.c(Boolean.FALSE);
                    } else {
                        jVar.c(Boolean.valueOf(q.e.b(c0579b.f5962c, (String) arrayListV.get(0))));
                    }
                    break;
                } else {
                    Log.d("permissions_handler", "Unable to detect current Activity.");
                    jVar.a(null, "PermissionHandler.PermissionManager", "Unable to detect current Android Activity.");
                    break;
                }
                break;
            case "checkPermissionStatus":
                jVar.c(Integer.valueOf(c0579b.c(Integer.parseInt(obj.toString()))));
                break;
            case "openAppSettings":
                if (context != null) {
                    try {
                        Intent intent2 = new Intent();
                        intent2.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
                        intent2.addCategory("android.intent.category.DEFAULT");
                        intent2.setData(Uri.parse("package:" + context.getPackageName()));
                        intent2.addFlags(268435456);
                        intent2.addFlags(1073741824);
                        intent2.addFlags(8388608);
                        context.startActivity(intent2);
                        jVar.c(Boolean.TRUE);
                    } catch (Exception unused) {
                        jVar.c(Boolean.FALSE);
                        return;
                    }
                    break;
                } else {
                    Log.d("permissions_handler", "Context cannot be null.");
                    jVar.a(null, "PermissionHandler.AppSettingsManager", "Android context cannot be null.");
                    break;
                }
                break;
            case "requestPermissions":
                List<Integer> list = (List) obj;
                N2.g gVar = new N2.g(jVar);
                if (c0579b.f5963d > 0) {
                    jVar.a(null, "PermissionHandler.PermissionManager", "A request for permissions is already running, please wait for it to finish before doing another request (note that you can request multiple permissions at the same time).");
                    break;
                } else if (c0579b.f5962c == null) {
                    Log.d("permissions_handler", "Unable to detect current Activity.");
                    jVar.a(null, "PermissionHandler.PermissionManager", "Unable to detect current Android Activity.");
                    break;
                } else {
                    c0579b.f5961b = gVar;
                    c0579b.e = new HashMap();
                    c0579b.f5963d = 0;
                    ArrayList arrayList = new ArrayList();
                    for (Integer num : list) {
                        if (c0579b.c(num.intValue()) != 1) {
                            ArrayList arrayListV2 = AbstractC0367g.v(c0579b.f5962c, num.intValue());
                            if (arrayListV2 != null && !arrayListV2.isEmpty()) {
                                int i6 = Build.VERSION.SDK_INT;
                                if (num.intValue() == 16) {
                                    c0579b.e(209, "android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS");
                                } else if (i6 >= 30 && num.intValue() == 22) {
                                    c0579b.e(210, "android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
                                } else if (num.intValue() == 23) {
                                    c0579b.e(211, "android.settings.action.MANAGE_OVERLAY_PERMISSION");
                                } else if (i6 >= 26 && num.intValue() == 24) {
                                    c0579b.e(212, "android.settings.MANAGE_UNKNOWN_APP_SOURCES");
                                } else if (num.intValue() == 27) {
                                    c0579b.e(213, "android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS");
                                } else if (i6 >= 31 && num.intValue() == 34) {
                                    c0579b.e(214, "android.settings.REQUEST_SCHEDULE_EXACT_ALARM");
                                } else if (num.intValue() != 37 && num.intValue() != 0) {
                                    arrayList.addAll(arrayListV2);
                                    c0579b.f5963d = arrayListV2.size() + c0579b.f5963d;
                                } else if (c0579b.d()) {
                                    arrayList.add("android.permission.WRITE_CALENDAR");
                                    arrayList.add("android.permission.READ_CALENDAR");
                                    c0579b.f5963d += 2;
                                } else {
                                    c0579b.e.put(num, 0);
                                }
                            } else if (!c0579b.e.containsKey(num)) {
                                c0579b.e.put(num, 0);
                                if (num.intValue() != 22 || Build.VERSION.SDK_INT >= 30) {
                                    c0579b.e.put(num, 0);
                                } else {
                                    c0579b.e.put(num, 2);
                                }
                            }
                        } else if (!c0579b.e.containsKey(num)) {
                            c0579b.e.put(num, 1);
                        }
                    }
                    if (arrayList.size() > 0) {
                        q.e.a(c0579b.f5962c, (String[]) arrayList.toArray(new String[0]), 24);
                    }
                    N2.g gVar2 = c0579b.f5961b;
                    if (gVar2 != null && c0579b.f5963d == 0) {
                        gVar2.f1162a.c(c0579b.e);
                        break;
                    }
                }
                break;
            default:
                jVar.b();
                break;
        }
    }

    @Override // io.ktor.utils.io.v
    public Z3.a h() {
        return ((C0449m) this.f3597b).h();
    }

    /* JADX WARN: Code restructure failed: missing block: B:20:0x0050, code lost:
    
        if (((io.ktor.utils.io.s) r5.f3598c).invoke(r0) == r1) goto L21;
     */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // io.ktor.utils.io.v
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object i(y3.InterfaceC0762c r6) {
        /*
            r5 = this;
            boolean r0 = r6 instanceof io.ktor.utils.io.B
            if (r0 == 0) goto L13
            r0 = r6
            io.ktor.utils.io.B r0 = (io.ktor.utils.io.B) r0
            int r1 = r0.f4954c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4954c = r1
            goto L18
        L13:
            io.ktor.utils.io.B r0 = new io.ktor.utils.io.B
            r0.<init>(r5, r6)
        L18:
            java.lang.Object r6 = r0.f4952a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4954c
            r3 = 2
            r4 = 1
            if (r2 == 0) goto L36
            if (r2 == r4) goto L32
            if (r2 != r3) goto L2a
            e1.AbstractC0367g.M(r6)
            goto L53
        L2a:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r0)
            throw r6
        L32:
            e1.AbstractC0367g.M(r6)
            goto L46
        L36:
            e1.AbstractC0367g.M(r6)
            r0.f4954c = r4
            java.lang.Object r6 = r5.f3597b
            io.ktor.utils.io.m r6 = (io.ktor.utils.io.C0449m) r6
            java.lang.Object r6 = r6.i(r0)
            if (r6 != r1) goto L46
            goto L52
        L46:
            r0.f4954c = r3
            java.lang.Object r6 = r5.f3598c
            io.ktor.utils.io.s r6 = (io.ktor.utils.io.s) r6
            java.lang.Object r6 = r6.invoke(r0)
            if (r6 != r1) goto L53
        L52:
            return r1
        L53:
            w3.i r6 = w3.i.f6729a
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.common.internal.r.i(y3.c):java.lang.Object");
    }

    @Override // N2.i
    public void j(int i4, double d5, double d6) {
        if (((io.flutter.plugin.platform.p) this.f3598c).s(i4) != null) {
            return;
        }
        ((io.flutter.plugin.platform.q) this.f3597b).f4665C.j(i4, d5, d6);
    }

    @Override // N2.i
    public void k(int i4, int i5) {
        io.flutter.plugin.platform.p pVar = (io.flutter.plugin.platform.p) this.f3598c;
        if (pVar.s(i4) != null) {
            pVar.v.k(i4, i5);
        } else {
            ((io.flutter.plugin.platform.q) this.f3597b).f4665C.k(i4, i5);
        }
    }

    @Override // N2.i
    public long l(N2.e eVar) {
        return ((io.flutter.plugin.platform.q) this.f3597b).f4665C.l(eVar);
    }

    @Override // io.flutter.plugin.platform.j
    public boolean m(int i4) {
        if (((io.flutter.plugin.platform.p) this.f3598c).s(i4) != null) {
            return false;
        }
        return ((io.flutter.plugin.platform.q) this.f3597b).m(i4);
    }

    @Override // io.ktor.utils.io.v
    public Object n(A3.c cVar) {
        return ((C0449m) this.f3597b).n(cVar);
    }

    @Override // io.ktor.utils.io.v
    public Throwable o() {
        return ((C0449m) this.f3597b).o();
    }

    @Override // com.google.android.gms.tasks.OnCompleteListener
    public void onComplete(Task task) {
        switch (this.f3596a) {
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                Intent intent = new Intent("android.intent.action.VIEW");
                GenericIdpActivity genericIdpActivity = (GenericIdpActivity) this.f3597b;
                ResolveInfo resolveInfoResolveActivity = genericIdpActivity.getPackageManager().resolveActivity(intent, 0);
                String str = (String) this.f3598c;
                if (resolveInfoResolveActivity == null) {
                    Log.e("GenericIdpActivity", "Device cannot resolve intent for: android.intent.action.VIEW");
                    zzacl.zzb(genericIdpActivity, str);
                } else {
                    List<ResolveInfo> listQueryIntentServices = genericIdpActivity.getPackageManager().queryIntentServices(new Intent("android.support.customtabs.action.CustomTabsService"), 0);
                    if (listQueryIntentServices == null || listQueryIntentServices.isEmpty()) {
                        Intent intent2 = new Intent("android.intent.action.VIEW", (Uri) task.getResult());
                        intent2.putExtra("com.android.browser.application_id", str);
                        Log.i("GenericIdpActivity", "Opening IDP Sign In link in a browser window.");
                        intent2.addFlags(1073741824);
                        intent2.addFlags(268435456);
                        genericIdpActivity.startActivity(intent2);
                    } else {
                        Intent intent3 = new Intent("android.intent.action.VIEW");
                        if (!intent3.hasExtra("android.support.customtabs.extra.SESSION")) {
                            Bundle bundle = new Bundle();
                            bundle.putBinder("android.support.customtabs.extra.SESSION", null);
                            intent3.putExtras(bundle);
                        }
                        intent3.putExtra("android.support.customtabs.extra.EXTRA_ENABLE_INSTANT_APPS", true);
                        intent3.putExtras(new Bundle());
                        intent3.putExtra("androidx.browser.customtabs.extra.SHARE_STATE", 0);
                        Log.i("GenericIdpActivity", "Opening IDP Sign In link in a custom chrome tab.");
                        intent3.setData((Uri) task.getResult());
                        r.h.startActivity(genericIdpActivity, intent3, null);
                    }
                }
                break;
            default:
                RecaptchaActivity recaptchaActivity = (RecaptchaActivity) this.f3597b;
                recaptchaActivity.getClass();
                ResolveInfo resolveInfoResolveActivity2 = recaptchaActivity.getPackageManager().resolveActivity(new Intent("android.intent.action.VIEW"), 0);
                String str2 = (String) this.f3598c;
                if (resolveInfoResolveActivity2 == null) {
                    Log.e("RecaptchaActivity", "Device cannot resolve intent for: android.intent.action.VIEW");
                    zzacl.zzb(recaptchaActivity, str2);
                } else {
                    List<ResolveInfo> listQueryIntentServices2 = recaptchaActivity.getPackageManager().queryIntentServices(new Intent("android.support.customtabs.action.CustomTabsService"), 0);
                    if (listQueryIntentServices2 == null || listQueryIntentServices2.isEmpty()) {
                        Intent intent4 = new Intent("android.intent.action.VIEW", (Uri) task.getResult());
                        intent4.putExtra("com.android.browser.application_id", str2);
                        intent4.addFlags(1073741824);
                        intent4.addFlags(268435456);
                        recaptchaActivity.startActivity(intent4);
                    } else {
                        Intent intent5 = new Intent("android.intent.action.VIEW");
                        if (!intent5.hasExtra("android.support.customtabs.extra.SESSION")) {
                            Bundle bundle2 = new Bundle();
                            bundle2.putBinder("android.support.customtabs.extra.SESSION", null);
                            intent5.putExtras(bundle2);
                        }
                        intent5.putExtra("android.support.customtabs.extra.EXTRA_ENABLE_INSTANT_APPS", true);
                        intent5.putExtras(new Bundle());
                        intent5.putExtra("androidx.browser.customtabs.extra.SHARE_STATE", 0);
                        intent5.addFlags(1073741824);
                        intent5.addFlags(268435456);
                        intent5.setData((Uri) task.getResult());
                        r.h.startActivity(recaptchaActivity, intent5, null);
                    }
                }
                break;
        }
    }

    @Override // N2.i
    public void p(int i4) {
        io.flutter.plugin.platform.p pVar = (io.flutter.plugin.platform.p) this.f3598c;
        if (pVar.s(i4) != null) {
            pVar.v.p(i4);
        } else {
            ((io.flutter.plugin.platform.q) this.f3597b).f4665C.p(i4);
        }
    }

    @Override // N2.i
    public void q(N2.f fVar) {
        io.flutter.plugin.platform.p pVar = (io.flutter.plugin.platform.p) this.f3598c;
        if (pVar.s(fVar.f1147a) != null) {
            pVar.v.q(fVar);
        } else {
            ((io.flutter.plugin.platform.q) this.f3597b).f4665C.q(fVar);
        }
    }

    @Override // N2.i
    public void r(N2.h hVar, N2.g gVar) {
        if (((io.flutter.plugin.platform.p) this.f3598c).s(hVar.f1163a) != null) {
            return;
        }
        ((io.flutter.plugin.platform.q) this.f3597b).f4665C.r(hVar, gVar);
    }

    @Override // io.flutter.plugin.platform.j
    public FrameLayout s(int i4) {
        io.flutter.plugin.platform.p pVar = (io.flutter.plugin.platform.p) this.f3598c;
        return pVar.s(i4) != null ? pVar.s(i4) : ((io.flutter.plugin.platform.q) this.f3597b).s(i4);
    }

    @Override // io.ktor.utils.io.v
    public void t(Throwable th) {
        ((C0449m) this.f3597b).t(th);
    }

    @Override // com.google.android.gms.tasks.Continuation
    public Object then(Task task) {
        if (!task.isSuccessful()) {
            Exception exception = task.getException();
            F.g(exception);
            String message = exception.getMessage();
            F.g(message);
            return Tasks.forException(new k1.o(message));
        }
        zzafj zzafjVar = (zzafj) task.getResult();
        String strZza = zzafjVar.zza();
        boolean zZzc = zzah.zzc(strZza);
        String str = (String) this.f3597b;
        if (zZzc) {
            return Tasks.forException(new k1.o(B1.a.m("No Recaptcha Enterprise siteKey configured for tenant/project ", str)));
        }
        List<String> listZza = zzac.zza('/').zza((CharSequence) strZza);
        String str2 = listZza.size() != 4 ? null : listZza.get(3);
        if (TextUtils.isEmpty(str2)) {
            return Tasks.forException(new Exception(B1.a.m("Invalid siteKey format ", strZza)));
        }
        if (Log.isLoggable("RecaptchaHandler", 4)) {
            Log.i("RecaptchaHandler", "Successfully obtained site key for tenant " + str);
        }
        R0.k kVar = (R0.k) this.f3598c;
        kVar.f1692c = zzafjVar;
        k1.t tVar = (k1.t) kVar.f1694f;
        g1.f fVar = (g1.f) kVar.f1693d;
        fVar.a();
        Application application = (Application) fVar.f4307a;
        tVar.getClass();
        Task<RecaptchaTasksClient> tasksClient = Recaptcha.getTasksClient(application, str2);
        ((HashMap) kVar.f1691b).put(str, tasksClient);
        return tasksClient;
    }

    public String toString() {
        switch (this.f3596a) {
            case 0:
                StringBuilder sb = new StringBuilder(100);
                sb.append(this.f3598c.getClass().getSimpleName());
                sb.append('{');
                ArrayList arrayList = (ArrayList) this.f3597b;
                int size = arrayList.size();
                for (int i4 = 0; i4 < size; i4++) {
                    sb.append((String) arrayList.get(i4));
                    if (i4 < size - 1) {
                        sb.append(", ");
                    }
                }
                sb.append('}');
                return sb.toString();
            default:
                return super.toString();
        }
    }

    @Override // io.ktor.utils.io.v
    public boolean u() {
        return false;
    }

    public void v(Object obj, String str) {
        ((ArrayList) this.f3597b).add(str + "=" + String.valueOf(obj));
    }

    public void w() {
        Y.e eVar;
        ImageView imageView = (ImageView) this.f3597b;
        Drawable drawable = imageView.getDrawable();
        if (drawable != null) {
            Rect rect = AbstractC0508z.f5489a;
        }
        if (drawable == null || (eVar = (Y.e) this.f3598c) == null) {
            return;
        }
        C0498o.c(drawable, eVar, imageView.getDrawableState());
    }

    public String x() {
        return ((Context) this.f3598c).getPackageName() + ".FlutterSecureStoragePluginKey";
    }

    public AlgorithmParameterSpec y() {
        return null;
    }

    public Cipher z() {
        return Cipher.getInstance("RSA/ECB/PKCS1Padding", "AndroidKeyStoreBCWorkaround");
    }

    public /* synthetic */ r(int i4, boolean z4) {
        this.f3596a = i4;
    }

    public r(Context context, int i4) throws NoSuchAlgorithmException, IOException, KeyStoreException, CertificateException {
        this.f3596a = i4;
        switch (i4) {
            case 22:
                this.f3598c = context;
                String strX = x();
                this.f3597b = strX;
                KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
                keyStore.load(null);
                if (keyStore.getKey(strX, null) == null) {
                    Locale locale = Locale.getDefault();
                    try {
                        E(Locale.ENGLISH);
                        Calendar calendar = Calendar.getInstance();
                        Calendar calendar2 = Calendar.getInstance();
                        calendar2.add(1, 25);
                        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA", "AndroidKeyStore");
                        keyPairGenerator.initialize(C(calendar, calendar2));
                        keyPairGenerator.generateKeyPair();
                        return;
                    } finally {
                        E(locale);
                    }
                }
                return;
            default:
                F.g(context);
                Resources resources = context.getResources();
                this.f3597b = resources;
                this.f3598c = resources.getResourcePackageName(R.string.common_google_play_services_unknown_issue);
                return;
        }
    }

    public /* synthetic */ r(Object obj) {
        this.f3596a = 0;
        this.f3598c = obj;
        this.f3597b = new ArrayList();
    }

    public r(int i4) {
        this.f3596a = i4;
        switch (i4) {
            case 3:
                this.f3597b = new ReentrantLock();
                this.f3598c = new LinkedHashMap();
                break;
            case 15:
                HashMap map = new HashMap();
                ArrayList arrayList = new ArrayList();
                this.f3597b = map;
                this.f3598c = arrayList;
                break;
            default:
                C0774e c0774e = C0774e.f6959d;
                this.f3597b = new SparseIntArray();
                this.f3598c = c0774e;
                break;
        }
    }

    public r(Context context, X.N n4, C0579b c0579b, X.N n5) {
        this.f3596a = 16;
        this.f3597b = context;
        this.f3598c = c0579b;
    }

    public r(R0.k kVar, String str) {
        this.f3596a = 13;
        this.f3597b = str;
        this.f3598c = kVar;
    }

    public r(View view, InputMethodManager inputMethodManager, C0690c c0690c) {
        this.f3596a = 6;
        if (Build.VERSION.SDK_INT >= 33) {
            view.setAutoHandwritingEnabled(false);
        }
        this.f3598c = view;
        this.f3597b = inputMethodManager;
        c0690c.f6642b = this;
    }

    public r(i0.b bVar) {
        this.f3596a = 4;
        r rVar = new r(3);
        this.f3597b = bVar;
        this.f3598c = rVar;
    }

    public r(ImageView imageView) {
        this.f3596a = 9;
        this.f3597b = imageView;
    }
}
