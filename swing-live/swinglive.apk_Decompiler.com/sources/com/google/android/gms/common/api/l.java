package com.google.android.gms.common.api;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import com.google.android.gms.common.api.internal.A;
import com.google.android.gms.common.api.internal.AbstractC0256d;
import com.google.android.gms.common.api.internal.AbstractC0264l;
import com.google.android.gms.common.api.internal.AbstractC0269q;
import com.google.android.gms.common.api.internal.AbstractC0273v;
import com.google.android.gms.common.api.internal.AbstractC0274w;
import com.google.android.gms.common.api.internal.AbstractServiceConnectionC0266n;
import com.google.android.gms.common.api.internal.C0253a;
import com.google.android.gms.common.api.internal.C0259g;
import com.google.android.gms.common.api.internal.C0265m;
import com.google.android.gms.common.api.internal.DialogInterfaceOnCancelListenerC0277z;
import com.google.android.gms.common.api.internal.E;
import com.google.android.gms.common.api.internal.H;
import com.google.android.gms.common.api.internal.InterfaceC0263k;
import com.google.android.gms.common.api.internal.InterfaceC0271t;
import com.google.android.gms.common.api.internal.LifecycleCallback;
import com.google.android.gms.common.api.internal.N;
import com.google.android.gms.common.api.internal.O;
import com.google.android.gms.common.api.internal.U;
import com.google.android.gms.common.internal.AbstractC0283f;
import com.google.android.gms.common.internal.C0284g;
import com.google.android.gms.common.internal.C0285h;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.internal.base.zaq;
import com.google.android.gms.internal.common.zzi;
import com.google.android.gms.tasks.Task;
import java.lang.reflect.InvocationTargetException;
import java.util.Collections;
import java.util.Set;
import org.checkerframework.checker.initialization.qual.NotOnlyInitialized;
import z0.C0774e;

/* JADX INFO: loaded from: classes.dex */
public abstract class l {
    protected final C0259g zaa;
    private final Context zab;
    private final String zac;
    private final i zad;
    private final e zae;
    private final C0253a zaf;
    private final Looper zag;
    private final int zah;

    @NotOnlyInitialized
    private final o zai;
    private final InterfaceC0271t zaj;

    public l(Context context, Activity activity, i iVar, e eVar, k kVar) {
        F.h(context, "Null context is not permitted.");
        F.h(iVar, "Api must not be null.");
        F.h(kVar, "Settings must not be null; use Settings.DEFAULT_SETTINGS instead.");
        this.zab = context.getApplicationContext();
        String str = null;
        if (Build.VERSION.SDK_INT >= 30) {
            try {
                str = (String) Context.class.getMethod("getAttributionTag", new Class[0]).invoke(context, new Object[0]);
            } catch (IllegalAccessException | NoSuchMethodException | InvocationTargetException unused) {
            }
        }
        this.zac = str;
        this.zad = iVar;
        this.zae = eVar;
        this.zag = kVar.f3501b;
        C0253a c0253a = new C0253a(iVar, eVar, str);
        this.zaf = c0253a;
        this.zai = new H(this);
        C0259g c0259gG = C0259g.g(this.zab);
        this.zaa = c0259gG;
        this.zah = c0259gG.f3475h.getAndIncrement();
        this.zaj = kVar.f3500a;
        if (activity != null && !(activity instanceof GoogleApiActivity) && Looper.myLooper() == Looper.getMainLooper()) {
            InterfaceC0263k fragment = LifecycleCallback.getFragment(activity);
            DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z = (DialogInterfaceOnCancelListenerC0277z) fragment.e(DialogInterfaceOnCancelListenerC0277z.class, "ConnectionlessLifecycleHelper");
            if (dialogInterfaceOnCancelListenerC0277z == null) {
                Object obj = C0774e.f6958c;
                dialogInterfaceOnCancelListenerC0277z = new DialogInterfaceOnCancelListenerC0277z(fragment, c0259gG);
            }
            dialogInterfaceOnCancelListenerC0277z.e.add(c0253a);
            c0259gG.b(dialogInterfaceOnCancelListenerC0277z);
        }
        zaq zaqVar = c0259gG.f3481n;
        zaqVar.sendMessage(zaqVar.obtainMessage(7, this));
    }

    public final void a(int i4, AbstractC0256d abstractC0256d) {
        abstractC0256d.zak();
        C0259g c0259g = this.zaa;
        c0259g.getClass();
        U u4 = new U(i4, abstractC0256d);
        zaq zaqVar = c0259g.f3481n;
        zaqVar.sendMessage(zaqVar.obtainMessage(4, new N(u4, c0259g.f3476i.get(), this)));
    }

    public o asGoogleApiClient() {
        return this.zai;
    }

    /* JADX WARN: Removed duplicated region for block: B:25:0x005c  */
    /* JADX WARN: Removed duplicated region for block: B:28:0x0064  */
    /* JADX WARN: Removed duplicated region for block: B:29:0x0069  */
    /* JADX WARN: Removed duplicated region for block: B:31:0x006c  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final com.google.android.gms.tasks.Task b(int r14, com.google.android.gms.common.api.internal.AbstractC0273v r15) {
        /*
            r13 = this;
            com.google.android.gms.tasks.TaskCompletionSource r0 = new com.google.android.gms.tasks.TaskCompletionSource
            r0.<init>()
            com.google.android.gms.common.api.internal.g r2 = r13.zaa
            com.google.android.gms.common.api.internal.t r9 = r13.zaj
            r2.getClass()
            int r3 = r15.f3489c
            com.google.android.gms.internal.base.zaq r10 = r2.f3481n
            if (r3 == 0) goto L87
            com.google.android.gms.common.api.internal.a r4 = r13.getApiKey()
            boolean r1 = r2.c()
            r5 = 0
            if (r1 != 0) goto L1e
            goto L75
        L1e:
            com.google.android.gms.common.internal.t r1 = com.google.android.gms.common.internal.t.b()
            java.lang.Object r1 = r1.f3601a
            com.google.android.gms.common.internal.u r1 = (com.google.android.gms.common.internal.u) r1
            r6 = 1
            if (r1 == 0) goto L5e
            boolean r7 = r1.f3603b
            if (r7 != 0) goto L2e
            goto L75
        L2e:
            java.util.concurrent.ConcurrentHashMap r7 = r2.f3477j
            java.lang.Object r7 = r7.get(r4)
            com.google.android.gms.common.api.internal.E r7 = (com.google.android.gms.common.api.internal.E) r7
            if (r7 == 0) goto L5c
            com.google.android.gms.common.api.g r8 = r7.f3394b
            boolean r11 = r8 instanceof com.google.android.gms.common.internal.AbstractC0283f
            if (r11 != 0) goto L3f
            goto L75
        L3f:
            com.google.android.gms.common.internal.f r8 = (com.google.android.gms.common.internal.AbstractC0283f) r8
            boolean r11 = r8.hasConnectionInfo()
            if (r11 == 0) goto L5c
            boolean r11 = r8.isConnecting()
            if (r11 != 0) goto L5c
            com.google.android.gms.common.internal.i r1 = com.google.android.gms.common.api.internal.L.a(r7, r8, r3)
            if (r1 != 0) goto L54
            goto L75
        L54:
            int r5 = r7.f3403l
            int r5 = r5 + r6
            r7.f3403l = r5
            boolean r6 = r1.f3565c
            goto L5e
        L5c:
            boolean r6 = r1.f3604c
        L5e:
            com.google.android.gms.common.api.internal.L r1 = new com.google.android.gms.common.api.internal.L
            r7 = 0
            if (r6 == 0) goto L69
            long r11 = java.lang.System.currentTimeMillis()
            goto L6a
        L69:
            r11 = r7
        L6a:
            if (r6 == 0) goto L70
            long r7 = android.os.SystemClock.elapsedRealtime()
        L70:
            r5 = r11
            r1.<init>(r2, r3, r4, r5, r7)
            r5 = r1
        L75:
            if (r5 == 0) goto L87
            com.google.android.gms.tasks.Task r1 = r0.getTask()
            r10.getClass()
            com.google.android.gms.common.api.internal.B r3 = new com.google.android.gms.common.api.internal.B
            r4 = 0
            r3.<init>(r10, r4)
            r1.addOnCompleteListener(r3, r5)
        L87:
            com.google.android.gms.common.api.internal.V r1 = new com.google.android.gms.common.api.internal.V
            r1.<init>(r14, r15, r0, r9)
            com.google.android.gms.common.api.internal.N r14 = new com.google.android.gms.common.api.internal.N
            java.util.concurrent.atomic.AtomicInteger r15 = r2.f3476i
            int r15 = r15.get()
            r14.<init>(r1, r15, r13)
            r15 = 4
            android.os.Message r14 = r10.obtainMessage(r15, r14)
            r10.sendMessage(r14)
            com.google.android.gms.tasks.Task r14 = r0.getTask()
            return r14
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.common.api.l.b(int, com.google.android.gms.common.api.internal.v):com.google.android.gms.tasks.Task");
    }

    public C0284g createClientSettingsBuilder() {
        C0284g c0284g = new C0284g();
        Set set = Collections.EMPTY_SET;
        if (c0284g.f3554a == null) {
            c0284g.f3554a = new n.c(0);
        }
        c0284g.f3554a.addAll(set);
        c0284g.f3556c = this.zab.getClass().getName();
        c0284g.f3555b = this.zab.getPackageName();
        return c0284g;
    }

    public Task<Boolean> disconnectService() {
        C0259g c0259g = this.zaa;
        c0259g.getClass();
        A a5 = new A(getApiKey());
        zaq zaqVar = c0259g.f3481n;
        zaqVar.sendMessage(zaqVar.obtainMessage(14, a5));
        return a5.f3386b.getTask();
    }

    public <A extends b, T extends AbstractC0256d> T doBestEffortWrite(T t4) {
        a(2, t4);
        return t4;
    }

    public <A extends b, T extends AbstractC0256d> T doRead(T t4) {
        a(0, t4);
        return t4;
    }

    @Deprecated
    public <A extends b, T extends AbstractC0269q, U extends AbstractC0274w> Task<Void> doRegisterEventListener(T t4, U u4) {
        F.g(t4);
        throw null;
    }

    public Task<Boolean> doUnregisterEventListener(AbstractC0264l abstractC0264l) {
        return doUnregisterEventListener(abstractC0264l, 0);
    }

    public <A extends b, T extends AbstractC0256d> T doWrite(T t4) {
        a(1, t4);
        return t4;
    }

    public final C0253a getApiKey() {
        return this.zaf;
    }

    public e getApiOptions() {
        return this.zae;
    }

    public Context getApplicationContext() {
        return this.zab;
    }

    public String getContextAttributionTag() {
        return this.zac;
    }

    @Deprecated
    public String getContextFeatureId() {
        return this.zac;
    }

    public Looper getLooper() {
        return this.zag;
    }

    public <L> C0265m registerListener(L l2, String str) {
        Looper looper = this.zag;
        F.h(l2, "Listener must not be null");
        F.h(looper, "Looper must not be null");
        F.h(str, "Listener type must not be null");
        C0265m c0265m = new C0265m();
        new zzi(looper);
        c0265m.f3484a = l2;
        F.d(str);
        return c0265m;
    }

    public final int zaa() {
        return this.zah;
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final g zab(Looper looper, E e) {
        C0284g c0284gCreateClientSettingsBuilder = createClientSettingsBuilder();
        C0285h c0285h = new C0285h(c0284gCreateClientSettingsBuilder.f3554a, c0284gCreateClientSettingsBuilder.f3555b, c0284gCreateClientSettingsBuilder.f3556c);
        a aVar = this.zad.f3382a;
        F.g(aVar);
        g gVarBuildClient = aVar.buildClient(this.zab, looper, c0285h, (Object) this.zae, (m) e, (n) e);
        String contextAttributionTag = getContextAttributionTag();
        if (contextAttributionTag != null && (gVarBuildClient instanceof AbstractC0283f)) {
            ((AbstractC0283f) gVarBuildClient).setAttributionTag(contextAttributionTag);
        }
        if (contextAttributionTag == null || !(gVarBuildClient instanceof AbstractServiceConnectionC0266n)) {
            return gVarBuildClient;
        }
        B1.a.p(gVarBuildClient);
        throw null;
    }

    public final O zac(Context context, Handler handler) {
        C0284g c0284gCreateClientSettingsBuilder = createClientSettingsBuilder();
        return new O(context, handler, new C0285h(c0284gCreateClientSettingsBuilder.f3554a, c0284gCreateClientSettingsBuilder.f3555b, c0284gCreateClientSettingsBuilder.f3556c));
    }

    public <TResult, A extends b> Task<TResult> doBestEffortWrite(AbstractC0273v abstractC0273v) {
        return b(2, abstractC0273v);
    }

    public <TResult, A extends b> Task<TResult> doRead(AbstractC0273v abstractC0273v) {
        return b(0, abstractC0273v);
    }

    public <A extends b> Task<Void> doRegisterEventListener(com.google.android.gms.common.api.internal.r rVar) {
        F.g(rVar);
        throw null;
    }

    public Task<Boolean> doUnregisterEventListener(AbstractC0264l abstractC0264l, int i4) {
        F.h(abstractC0264l, "Listener key cannot be null.");
        throw null;
    }

    public <TResult, A extends b> Task<TResult> doWrite(AbstractC0273v abstractC0273v) {
        return b(1, abstractC0273v);
    }
}
