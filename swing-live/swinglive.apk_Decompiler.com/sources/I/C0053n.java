package I;

import A.C0003c;
import O.AbstractComponentCallbacksC0109u;
import Q3.InterfaceC0132h0;
import android.accounts.Account;
import android.content.Context;
import android.content.SharedPreferences;
import android.opengl.EGL14;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.text.SpannableString;
import android.text.style.LocaleSpan;
import android.text.style.TtsSpan;
import android.text.style.URLSpan;
import android.util.Log;
import b.C0236m;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.auth.zze;
import com.google.android.gms.internal.p002firebaseauthapi.zzach;
import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.android.recaptcha.RecaptchaAction;
import com.google.firebase.auth.FirebaseAuth;
import f1.C0400a;
import io.flutter.embedding.engine.FlutterJNI;
import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;
import javax.net.ssl.X509TrustManager;
import o3.C0592H;
import q0.AbstractC0630d;
import q0.InterfaceC0633g;
import u1.C0690c;
import x1.EnumC0716a;
import x1.EnumC0718c;
import x3.AbstractC0728h;
import z0.C0779j;

/* JADX INFO: renamed from: I.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0053n implements Continuation, InterfaceC0633g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f705a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f706b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f707c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f708d;
    public Object e;

    public /* synthetic */ C0053n(int i4, boolean z4) {
        this.f705a = i4;
    }

    public void A() {
        if (EGL14.eglSwapBuffers((EGLDisplay) this.f708d, (EGLSurface) this.f707c)) {
            return;
        }
        Log.e("SurfaceManager", "eglSwapBuffers failed");
    }

    public void a(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (((ArrayList) this.f706b).contains(abstractComponentCallbacksC0109u)) {
            throw new IllegalStateException("Fragment already added: " + abstractComponentCallbacksC0109u);
        }
        synchronized (((ArrayList) this.f706b)) {
            ((ArrayList) this.f706b).add(abstractComponentCallbacksC0109u);
        }
        abstractComponentCallbacksC0109u.f1417q = true;
    }

    @Override // q0.InterfaceC0633g
    public Object b(IBinder iBinder) throws IOException {
        Bundle bundleZze = zze.zzb(iBinder).zze((Account) this.f706b, (String) this.f707c, (Bundle) this.f708d);
        if (bundleZze != null) {
            return AbstractC0630d.c((Context) this.e, bundleZze);
        }
        throw new IOException("Service call returned null");
    }

    public S0.f c() throws GeneralSecurityException {
        C0690c c0690c;
        S0.k kVar = (S0.k) this.f706b;
        if (kVar == null) {
            throw new GeneralSecurityException("Cannot build without parameters");
        }
        C0690c c0690c2 = (C0690c) this.f707c;
        if (c0690c2 == null || (c0690c = (C0690c) this.f708d) == null) {
            throw new GeneralSecurityException("Cannot build without key material");
        }
        if (kVar.f1760b != ((C0400a) c0690c2.f6642b).f4284a.length) {
            throw new GeneralSecurityException("AES key size mismatch");
        }
        if (kVar.f1761c != ((C0400a) c0690c.f6642b).f4284a.length) {
            throw new GeneralSecurityException("HMAC key size mismatch");
        }
        S0.j jVar = S0.j.f1743j;
        S0.j jVar2 = kVar.e;
        if (jVar2 != jVar && ((Integer) this.e) == null) {
            throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
        }
        if (jVar2 == jVar && ((Integer) this.e) != null) {
            throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
        }
        if (jVar2 == jVar) {
            C0400a.a(new byte[0]);
        } else if (jVar2 == S0.j.f1742i) {
            C0400a.a(ByteBuffer.allocate(5).put((byte) 0).putInt(((Integer) this.e).intValue()).array());
        } else {
            if (jVar2 != S0.j.f1741h) {
                throw new IllegalStateException("Unknown AesCtrHmacAeadParameters.Variant: " + ((S0.k) this.f706b).e);
            }
            C0400a.a(ByteBuffer.allocate(5).put((byte) 1).putInt(((Integer) this.e).intValue()).array());
        }
        return new S0.f();
    }

    public Z0.k d() {
        Integer num = (Integer) this.f706b;
        if (num == null) {
            throw new GeneralSecurityException("key size is not set");
        }
        if (((Integer) this.f707c) == null) {
            throw new GeneralSecurityException("tag size is not set");
        }
        if (((Z0.d) this.f708d) == null) {
            throw new GeneralSecurityException("hash type is not set");
        }
        if (((Z0.d) this.e) == null) {
            throw new GeneralSecurityException("variant is not set");
        }
        if (num.intValue() < 16) {
            throw new InvalidAlgorithmParameterException(String.format("Invalid key size in bytes %d; must be at least 16 bytes", (Integer) this.f706b));
        }
        Integer num2 = (Integer) this.f707c;
        int iIntValue = num2.intValue();
        Z0.d dVar = (Z0.d) this.f708d;
        if (iIntValue < 10) {
            throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; must be at least 10 bytes", num2));
        }
        if (dVar == Z0.d.f2559g) {
            if (iIntValue > 20) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 20 bytes for SHA1", num2));
            }
        } else if (dVar == Z0.d.f2560h) {
            if (iIntValue > 28) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 28 bytes for SHA224", num2));
            }
        } else if (dVar == Z0.d.f2561i) {
            if (iIntValue > 32) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 32 bytes for SHA256", num2));
            }
        } else if (dVar == Z0.d.f2562j) {
            if (iIntValue > 48) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 48 bytes for SHA384", num2));
            }
        } else {
            if (dVar != Z0.d.f2563k) {
                throw new GeneralSecurityException("unknown hash type; must be SHA256, SHA384 or SHA512");
            }
            if (iIntValue > 64) {
                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 64 bytes for SHA512", num2));
            }
        }
        return new Z0.k(((Integer) this.f706b).intValue(), ((Integer) this.f707c).intValue(), (Z0.d) this.e, (Z0.d) this.f708d);
    }

    public SpannableString e() {
        if (((String) this.f706b) == null) {
            return null;
        }
        SpannableString spannableString = new SpannableString((String) this.f706b);
        ArrayList<io.flutter.view.n> arrayList = (ArrayList) this.f707c;
        if (arrayList != null) {
            for (io.flutter.view.n nVar : arrayList) {
                int iB = K.j.b(nVar.f4813c);
                if (iB == 0) {
                    spannableString.setSpan(new TtsSpan.Builder("android.type.verbatim").build(), nVar.f4811a, nVar.f4812b, 0);
                } else if (iB == 1) {
                    spannableString.setSpan(new LocaleSpan(Locale.forLanguageTag(((io.flutter.view.l) nVar).f4810d)), nVar.f4811a, nVar.f4812b, 0);
                }
            }
        }
        String str = (String) this.e;
        if (str != null && !str.isEmpty()) {
            spannableString.setSpan(new URLSpan((String) this.e), 0, ((String) this.f706b).length(), 0);
        }
        String str2 = (String) this.f708d;
        if (str2 != null && !str2.isEmpty()) {
            spannableString.setSpan(new LocaleSpan(Locale.forLanguageTag((String) this.f708d)), 0, ((String) this.f706b).length(), 0);
        }
        return spannableString;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object f(A3.c r7) {
        /*
            r6 = this;
            boolean r0 = r7 instanceof I.C0049j
            if (r0 == 0) goto L13
            r0 = r7
            I.j r0 = (I.C0049j) r0
            int r1 = r0.f677d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f677d = r1
            goto L18
        L13:
            I.j r0 = new I.j
            r0.<init>(r6, r7)
        L18:
            java.lang.Object r7 = r0.f675b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f677d
            r3 = 2
            r4 = 1
            if (r2 == 0) goto L3a
            if (r2 == r4) goto L34
            if (r2 != r3) goto L2c
            I.n r0 = r0.f674a
            e1.AbstractC0367g.M(r7)
            goto L64
        L2c:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r0)
            throw r7
        L34:
            I.n r0 = r0.f674a
            e1.AbstractC0367g.M(r7)
            goto L74
        L3a:
            e1.AbstractC0367g.M(r7)
            java.lang.Object r7 = r6.f708d
            java.util.List r7 = (java.util.List) r7
            java.lang.Object r2 = r6.e
            I.Q r2 = (I.Q) r2
            if (r7 == 0) goto L67
            boolean r7 = r7.isEmpty()
            if (r7 == 0) goto L4e
            goto L67
        L4e:
            I.l0 r7 = r2.f()
            I.m r4 = new I.m
            r5 = 0
            r4.<init>(r2, r6, r5)
            r0.f674a = r6
            r0.f677d = r3
            java.lang.Object r7 = r7.b(r4, r0)
            if (r7 != r1) goto L63
            goto L72
        L63:
            r0 = r6
        L64:
            I.d r7 = (I.C0043d) r7
            goto L76
        L67:
            r0.f674a = r6
            r0.f677d = r4
            r7 = 0
            java.lang.Object r7 = I.Q.e(r2, r7, r0)
            if (r7 != r1) goto L73
        L72:
            return r1
        L73:
            r0 = r6
        L74:
            I.d r7 = (I.C0043d) r7
        L76:
            java.lang.Object r0 = r0.e
            I.Q r0 = (I.Q) r0
            u1.c r0 = r0.f603n
            r0.A(r7)
            w3.i r7 = w3.i.f6729a
            return r7
        */
        throw new UnsupportedOperationException("Method not decompiled: I.C0053n.f(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:23:0x00e8  */
    /* JADX WARN: Removed duplicated region for block: B:24:0x00eb  */
    /* JADX WARN: Removed duplicated region for block: B:27:0x00f5  */
    /* JADX WARN: Removed duplicated region for block: B:28:0x010e  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void g(int r33, int r34, android.view.Surface r35, android.opengl.EGLContext r36) {
        /*
            Method dump skipped, instruction units count: 311
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: I.C0053n.g(int, int, android.view.Surface, android.opengl.EGLContext):void");
    }

    public AbstractComponentCallbacksC0109u h(String str) {
        O.U u4 = (O.U) ((HashMap) this.f707c).get(str);
        if (u4 != null) {
            return u4.f1289c;
        }
        return null;
    }

    public AbstractComponentCallbacksC0109u i(String str) {
        for (O.U u4 : ((HashMap) this.f707c).values()) {
            if (u4 != null) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uI = u4.f1289c;
                if (!str.equals(abstractComponentCallbacksC0109uI.e)) {
                    abstractComponentCallbacksC0109uI = abstractComponentCallbacksC0109uI.f1386A.f1239c.i(str);
                }
                if (abstractComponentCallbacksC0109uI != null) {
                    return abstractComponentCallbacksC0109uI;
                }
            }
        }
        return null;
    }

    public ArrayList j() {
        ArrayList arrayList = new ArrayList();
        for (O.U u4 : ((HashMap) this.f707c).values()) {
            if (u4 != null) {
                arrayList.add(u4);
            }
        }
        return arrayList;
    }

    public ArrayList k() {
        ArrayList arrayList = new ArrayList();
        for (O.U u4 : ((HashMap) this.f707c).values()) {
            if (u4 != null) {
                arrayList.add(u4.f1289c);
            } else {
                arrayList.add(null);
            }
        }
        return arrayList;
    }

    public List l() {
        ArrayList arrayList;
        if (((ArrayList) this.f706b).isEmpty()) {
            return Collections.EMPTY_LIST;
        }
        synchronized (((ArrayList) this.f706b)) {
            arrayList = new ArrayList((ArrayList) this.f706b);
        }
        return arrayList;
    }

    public File m(Context context) {
        ((C0592H) this.f707c).getClass();
        return new File(context.getDir("lib", 0), System.mapLibraryName("flutter"));
    }

    public void n(String str, Object... objArr) {
        String str2 = String.format(Locale.US, str, objArr);
        if (((C0003c) this.e) != null) {
            FlutterJNI.lambda$loadLibrary$0(str2);
        }
    }

    public void o(O.U u4) {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = u4.f1289c;
        String str = abstractComponentCallbacksC0109u.e;
        HashMap map = (HashMap) this.f707c;
        if (map.get(str) != null) {
            return;
        }
        map.put(abstractComponentCallbacksC0109u.e, u4);
        if (O.N.J(2)) {
            Log.v("FragmentManager", "Added fragment to active set " + abstractComponentCallbacksC0109u);
        }
    }

    public boolean p() {
        EGLDisplay eGLDisplay = (EGLDisplay) this.f708d;
        EGLSurface eGLSurface = (EGLSurface) this.f707c;
        if (EGL14.eglMakeCurrent(eGLDisplay, eGLSurface, eGLSurface, (EGLContext) this.f706b)) {
            return true;
        }
        Log.e("SurfaceManager", "eglMakeCurrent failed");
        return false;
    }

    public void q(O.U u4) {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = u4.f1289c;
        if (abstractComponentCallbacksC0109u.f1393H) {
            ((O.Q) this.e).e(abstractComponentCallbacksC0109u);
        }
        HashMap map = (HashMap) this.f707c;
        if (map.get(abstractComponentCallbacksC0109u.e) == u4 && ((O.U) map.put(abstractComponentCallbacksC0109u.e, null)) != null && O.N.J(2)) {
            Log.v("FragmentManager", "Removed fragment from active set " + abstractComponentCallbacksC0109u);
        }
    }

    public void r(Y0.a aVar) throws GeneralSecurityException {
        aVar.getClass();
        Y0.p pVar = new Y0.p(Y0.n.class, aVar.f2465a);
        HashMap map = (HashMap) this.f707c;
        if (!map.containsKey(pVar)) {
            map.put(pVar, aVar);
            return;
        }
        Y0.a aVar2 = (Y0.a) map.get(pVar);
        if (aVar2.equals(aVar) && aVar.equals(aVar2)) {
            return;
        }
        throw new GeneralSecurityException("Attempt to register non-equal parser for already existing object of type: " + pVar);
    }

    public void s(Y0.b bVar) throws GeneralSecurityException {
        Y0.q qVar = new Y0.q(bVar.f2467a, Y0.n.class);
        HashMap map = (HashMap) this.f706b;
        if (!map.containsKey(qVar)) {
            map.put(qVar, bVar);
            return;
        }
        Y0.b bVar2 = (Y0.b) map.get(qVar);
        if (bVar2.equals(bVar) && bVar.equals(bVar2)) {
            return;
        }
        throw new GeneralSecurityException("Attempt to register non-equal serializer for already existing object of type: " + qVar);
    }

    public void t(Y0.i iVar) throws GeneralSecurityException {
        iVar.getClass();
        Y0.p pVar = new Y0.p(Y0.o.class, iVar.f2480a);
        HashMap map = (HashMap) this.e;
        if (!map.containsKey(pVar)) {
            map.put(pVar, iVar);
            return;
        }
        Y0.i iVar2 = (Y0.i) map.get(pVar);
        if (iVar2.equals(iVar) && iVar.equals(iVar2)) {
            return;
        }
        throw new GeneralSecurityException("Attempt to register non-equal parser for already existing object of type: " + pVar);
    }

    @Override // com.google.android.gms.tasks.Continuation
    public Object then(Task task) {
        R0.k kVar;
        R0.k kVar2;
        switch (this.f705a) {
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                RecaptchaAction recaptchaAction = (RecaptchaAction) this.f706b;
                FirebaseAuth firebaseAuth = (FirebaseAuth) this.f707c;
                String str = (String) this.f708d;
                B.k kVar3 = (B.k) this.e;
                if (task.isSuccessful()) {
                    return Tasks.forResult(task.getResult());
                }
                Exception exception = task.getException();
                com.google.android.gms.common.internal.F.g(exception);
                if (!zzach.zzc(exception)) {
                    Log.e("RecaptchaCallWrapper", "Initial task failed for action " + String.valueOf(recaptchaAction) + "with exception - " + exception.getMessage());
                    return Tasks.forException(exception);
                }
                if (Log.isLoggable("RecaptchaCallWrapper", 4)) {
                    Log.i("RecaptchaCallWrapper", "Falling back to recaptcha enterprise flow for action ".concat(String.valueOf(recaptchaAction)));
                }
                synchronized (firebaseAuth) {
                    kVar = firebaseAuth.f3849j;
                }
                if (kVar == null) {
                    g1.f fVar = firebaseAuth.f3841a;
                    k1.t tVar = new k1.t();
                    R0.k kVar4 = new R0.k(3);
                    kVar4.f1691b = new HashMap();
                    kVar4.f1693d = fVar;
                    kVar4.e = firebaseAuth;
                    kVar4.f1694f = tVar;
                    synchronized (firebaseAuth) {
                        firebaseAuth.f3849j = kVar4;
                    }
                }
                synchronized (firebaseAuth) {
                    kVar2 = firebaseAuth.f3849j;
                }
                return kVar2.j(str, Boolean.FALSE, recaptchaAction).continueWithTask(kVar3).continueWithTask(new C0053n(str, kVar2, recaptchaAction, kVar3, 12));
            default:
                if (task.isSuccessful()) {
                    return task;
                }
                Exception exception2 = task.getException();
                com.google.android.gms.common.internal.F.g(exception2);
                if (!zzach.zzb(exception2)) {
                    return task;
                }
                boolean zIsLoggable = Log.isLoggable("RecaptchaCallWrapper", 4);
                String str2 = (String) this.f706b;
                if (zIsLoggable) {
                    Log.i("RecaptchaCallWrapper", "Invalid token - Refreshing Recaptcha Enterprise config and fetching new token for tenant " + str2);
                }
                return ((R0.k) this.f707c).j(str2, Boolean.TRUE, (RecaptchaAction) this.f708d).continueWithTask((B.k) this.e);
        }
    }

    public void u(Y0.j jVar) throws GeneralSecurityException {
        Y0.q qVar = new Y0.q(jVar.f2481a, Y0.o.class);
        HashMap map = (HashMap) this.f708d;
        if (!map.containsKey(qVar)) {
            map.put(qVar, jVar);
            return;
        }
        Y0.j jVar2 = (Y0.j) map.get(qVar);
        if (jVar2.equals(jVar) && jVar.equals(jVar2)) {
            return;
        }
        throw new GeneralSecurityException("Attempt to register non-equal serializer for already existing object of type: " + qVar);
    }

    public void v() {
        EGLDisplay eGLDisplay = (EGLDisplay) this.f708d;
        if (eGLDisplay != EGL14.EGL_NO_DISPLAY) {
            EGLSurface eGLSurface = EGL14.EGL_NO_SURFACE;
            EGL14.eglMakeCurrent(eGLDisplay, eGLSurface, eGLSurface, EGL14.EGL_NO_CONTEXT);
            EGL14.eglDestroySurface((EGLDisplay) this.f708d, (EGLSurface) this.f707c);
            EGL14.eglDestroyContext((EGLDisplay) this.f708d, (EGLContext) this.f706b);
            EGL14.eglReleaseThread();
            EGL14.eglTerminate((EGLDisplay) this.f708d);
            Log.i("SurfaceManager", "GL released");
            this.f708d = EGL14.EGL_NO_DISPLAY;
            this.f706b = EGL14.EGL_NO_CONTEXT;
            this.f707c = EGL14.EGL_NO_SURFACE;
        } else {
            Log.e("SurfaceManager", "GL already released");
        }
        ((AtomicBoolean) this.e).set(false);
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object w(A3.c r8) throws java.lang.Throwable {
        /*
            r7 = this;
            boolean r0 = r8 instanceof I.f0
            if (r0 == 0) goto L13
            r0 = r8
            I.f0 r0 = (I.f0) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            I.f0 r0 = new I.f0
            r0.<init>(r7, r8)
        L18:
            java.lang.Object r8 = r0.f657c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            w3.i r3 = w3.i.f6729a
            r4 = 2
            r5 = 1
            r6 = 0
            if (r2 == 0) goto L44
            if (r2 == r5) goto L3b
            if (r2 != r4) goto L33
            Y3.a r1 = r0.f656b
            I.n r0 = r0.f655a
            e1.AbstractC0367g.M(r8)     // Catch: java.lang.Throwable -> L31
            goto L83
        L31:
            r8 = move-exception
            goto L95
        L33:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r0)
            throw r8
        L3b:
            Y3.a r2 = r0.f656b
            I.n r5 = r0.f655a
            e1.AbstractC0367g.M(r8)
            r8 = r2
            goto L64
        L44:
            e1.AbstractC0367g.M(r8)
            java.lang.Object r8 = r7.f707c
            Q3.s r8 = (Q3.C0146s) r8
            boolean r8 = r8.l()
            if (r8 == 0) goto L52
            return r3
        L52:
            r0.f655a = r7
            java.lang.Object r8 = r7.f706b
            Y3.d r8 = (Y3.d) r8
            r0.f656b = r8
            r0.e = r5
            java.lang.Object r2 = r8.c(r0)
            if (r2 != r1) goto L63
            goto L80
        L63:
            r5 = r7
        L64:
            java.lang.Object r2 = r5.f707c     // Catch: java.lang.Throwable -> L93
            Q3.s r2 = (Q3.C0146s) r2     // Catch: java.lang.Throwable -> L93
            boolean r2 = r2.l()     // Catch: java.lang.Throwable -> L93
            if (r2 == 0) goto L74
            Y3.d r8 = (Y3.d) r8
            r8.e(r6)
            return r3
        L74:
            r0.f655a = r5     // Catch: java.lang.Throwable -> L93
            r0.f656b = r8     // Catch: java.lang.Throwable -> L93
            r0.e = r4     // Catch: java.lang.Throwable -> L93
            java.lang.Object r0 = r5.f(r0)     // Catch: java.lang.Throwable -> L93
            if (r0 != r1) goto L81
        L80:
            return r1
        L81:
            r1 = r8
            r0 = r5
        L83:
            java.lang.Object r8 = r0.f707c     // Catch: java.lang.Throwable -> L31
            Q3.s r8 = (Q3.C0146s) r8     // Catch: java.lang.Throwable -> L31
            r8.O(r3)     // Catch: java.lang.Throwable -> L31
            Y3.d r1 = (Y3.d) r1
            r1.e(r6)
            return r3
        L90:
            r1 = r8
            r8 = r0
            goto L95
        L93:
            r0 = move-exception
            goto L90
        L95:
            Y3.d r1 = (Y3.d) r1
            r1.e(r6)
            throw r8
        */
        throw new UnsupportedOperationException("Method not decompiled: I.C0053n.w(A3.c):java.lang.Object");
    }

    public void x(Serializable serializable, O2.c cVar) {
        ((O2.f) this.f706b).s((String) this.f707c, ((O2.l) this.f708d).b(serializable), cVar == null ? null : new O2.a(0, this, cVar));
    }

    public void y(O2.b bVar) {
        String str = (String) this.f707c;
        O2.f fVar = (O2.f) this.f706b;
        p1.d dVar = (p1.d) this.e;
        if (dVar != null) {
            fVar.b(str, bVar != null ? new D2.v(14, this, bVar) : null, dVar);
        } else {
            fVar.p(str, bVar != null ? new D2.v(14, this, bVar) : null);
        }
    }

    public Bundle z(String str, Bundle bundle) {
        HashMap map = (HashMap) this.f708d;
        return bundle != null ? (Bundle) map.put(str, bundle) : (Bundle) map.remove(str);
    }

    public /* synthetic */ C0053n(Object obj, Object obj2, Object obj3, Object obj4, int i4) {
        this.f705a = i4;
        this.f706b = obj;
        this.f707c = obj2;
        this.f708d = obj3;
        this.e = obj4;
    }

    public C0053n(SecureRandom secureRandom, ArrayList arrayList, X509TrustManager x509TrustManager, ArrayList arrayList2) {
        this.f705a = 13;
        J3.i.e(arrayList, "certificates");
        J3.i.e(x509TrustManager, "trustManager");
        J3.i.e(arrayList2, "cipherSuites");
        this.f706b = secureRandom;
        this.f707c = arrayList;
        this.f708d = x509TrustManager;
        this.e = arrayList2;
    }

    public C0053n(Q3.D d5, C0236m c0236m, N n4) {
        this.f705a = 1;
        this.f706b = d5;
        this.f707c = n4;
        this.f708d = S3.m.a(com.google.android.gms.common.api.f.API_PRIORITY_OTHER, null, 6);
        this.e = new C0779j();
        InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) d5.n().i(Q3.B.f1565b);
        if (interfaceC0132h0 != null) {
            interfaceC0132h0.q(new g0(c0236m, this));
        }
    }

    public C0053n(int i4) {
        this.f705a = i4;
        switch (i4) {
            case 4:
                this.f706b = new ArrayList();
                this.f707c = new HashMap();
                this.f708d = new HashMap();
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                this.f706b = new HashMap();
                this.f707c = new HashMap();
                this.f708d = new HashMap();
                this.e = new HashMap();
                break;
            case 14:
                C0592H c0592h = new C0592H();
                C0592H c0592h2 = new C0592H();
                this.f706b = new HashSet();
                this.f707c = c0592h;
                this.f708d = c0592h2;
                break;
            default:
                this.f706b = EGL14.EGL_NO_CONTEXT;
                this.f707c = EGL14.EGL_NO_SURFACE;
                this.f708d = EGL14.EGL_NO_DISPLAY;
                this.e = new AtomicBoolean(false);
                break;
        }
    }

    public C0053n(Y0.r rVar) {
        this.f705a = 7;
        this.f706b = new HashMap(rVar.f2498a);
        this.f707c = new HashMap(rVar.f2499b);
        this.f708d = new HashMap(rVar.f2500c);
        this.e = new HashMap(rVar.f2501d);
    }

    public C0053n(SharedPreferences sharedPreferences, Map map) {
        this.f705a = 16;
        this.f706b = EnumC0716a.valueOf(sharedPreferences.getString("FlutterSecureSAlgorithmKey", "RSA_ECB_PKCS1Padding"));
        this.f707c = EnumC0718c.valueOf(sharedPreferences.getString("FlutterSecureSAlgorithmStorage", "AES_CBC_PKCS7Padding"));
        Object obj = map.get("keyCipherAlgorithm");
        EnumC0716a enumC0716aValueOf = EnumC0716a.valueOf(obj != null ? obj.toString() : "RSA_ECB_PKCS1Padding");
        int i4 = enumC0716aValueOf.f6766b;
        int i5 = Build.VERSION.SDK_INT;
        this.f708d = i4 > i5 ? EnumC0716a.RSA_ECB_PKCS1Padding : enumC0716aValueOf;
        Object obj2 = map.get("storageCipherAlgorithm");
        EnumC0718c enumC0718cValueOf = EnumC0718c.valueOf(obj2 != null ? obj2.toString() : "AES_CBC_PKCS7Padding");
        this.e = enumC0718cValueOf.f6770b > i5 ? EnumC0718c.AES_CBC_PKCS7Padding : enumC0718cValueOf;
    }

    public C0053n(Q q4, List list) {
        this.f705a = 0;
        this.e = q4;
        this.f706b = new Y3.d();
        this.f707c = Q3.F.a();
        this.f708d = AbstractC0728h.i0(list);
    }

    public C0053n(String str, String[] strArr, String str2, N2.p pVar) {
        this.f705a = 3;
        this.f706b = str;
        this.f707c = strArr;
        this.e = str2;
        this.f708d = pVar;
    }
}
