package com.google.android.gms.common.api.internal;

import android.os.Looper;
import com.google.android.gms.common.annotation.KeepName;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.s;
import com.google.android.gms.common.internal.InterfaceC0291n;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
@KeepName
public abstract class BasePendingResult<R extends com.google.android.gms.common.api.s> extends com.google.android.gms.common.api.q {
    static final ThreadLocal<Boolean> zaa = new J0.b(4);
    public static final /* synthetic */ int zad = 0;

    @KeepName
    private a0 mResultGuardian;
    protected final HandlerC0257e zab;
    protected final WeakReference<com.google.android.gms.common.api.o> zac;
    private com.google.android.gms.common.api.t zah;
    private R zaj;
    private Status zak;
    private volatile boolean zal;
    private boolean zam;
    private boolean zan;
    private InterfaceC0291n zao;
    private volatile S zap;
    private final Object zae = new Object();
    private final CountDownLatch zaf = new CountDownLatch(1);
    private final ArrayList<com.google.android.gms.common.api.p> zag = new ArrayList<>();
    private final AtomicReference<T> zai = new AtomicReference<>();
    private boolean zaq = false;

    public BasePendingResult(com.google.android.gms.common.api.o oVar) {
        this.zab = new HandlerC0257e(oVar != null ? ((H) oVar).f3412b.getLooper() : Looper.getMainLooper());
        this.zac = new WeakReference<>(oVar);
    }

    public static void zal(com.google.android.gms.common.api.s sVar) {
    }

    public final com.google.android.gms.common.api.s a() {
        R r4;
        synchronized (this.zae) {
            com.google.android.gms.common.internal.F.i("Result has already been consumed.", !this.zal);
            com.google.android.gms.common.internal.F.i("Result is not ready.", isReady());
            r4 = this.zaj;
            this.zaj = null;
            this.zah = null;
            this.zal = true;
        }
        if (this.zai.getAndSet(null) != null) {
            throw new ClassCastException();
        }
        com.google.android.gms.common.internal.F.g(r4);
        return r4;
    }

    public final void addStatusListener(com.google.android.gms.common.api.p pVar) {
        com.google.android.gms.common.internal.F.a("Callback cannot be null.", pVar != null);
        synchronized (this.zae) {
            try {
                if (isReady()) {
                    pVar.a(this.zak);
                } else {
                    this.zag.add(pVar);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final R await() {
        com.google.android.gms.common.internal.F.f("await must not be called on the UI thread");
        com.google.android.gms.common.internal.F.i("Result has already been consumed", !this.zal);
        com.google.android.gms.common.internal.F.i("Cannot await if then() has been called.", this.zap == null);
        try {
            this.zaf.await();
        } catch (InterruptedException unused) {
            forceFailureUnlessReady(Status.f3373m);
        }
        com.google.android.gms.common.internal.F.i("Result is not ready.", isReady());
        return (R) a();
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final void b(com.google.android.gms.common.api.s sVar) {
        this.zaj = sVar;
        this.zak = sVar.getStatus();
        this.zaf.countDown();
        if (this.zam) {
            this.zah = null;
        } else {
            com.google.android.gms.common.api.t tVar = this.zah;
            if (tVar != null) {
                this.zab.removeMessages(2);
                this.zab.a(tVar, a());
            }
        }
        ArrayList<com.google.android.gms.common.api.p> arrayList = this.zag;
        int size = arrayList.size();
        for (int i4 = 0; i4 < size; i4++) {
            arrayList.get(i4).a(this.zak);
        }
        this.zag.clear();
    }

    public void cancel() {
        synchronized (this.zae) {
            try {
                if (!this.zam && !this.zal) {
                    zal(this.zaj);
                    this.zam = true;
                    b(createFailedResult(Status.f3376p));
                }
            } finally {
            }
        }
    }

    public abstract com.google.android.gms.common.api.s createFailedResult(Status status);

    @Deprecated
    public final void forceFailureUnlessReady(Status status) {
        synchronized (this.zae) {
            try {
                if (!isReady()) {
                    setResult(createFailedResult(status));
                    this.zan = true;
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final boolean isCanceled() {
        boolean z4;
        synchronized (this.zae) {
            z4 = this.zam;
        }
        return z4;
    }

    public final boolean isReady() {
        return this.zaf.getCount() == 0;
    }

    public final void setCancelToken(InterfaceC0291n interfaceC0291n) {
        synchronized (this.zae) {
        }
    }

    public final void setResult(R r4) {
        synchronized (this.zae) {
            try {
                if (this.zan || this.zam) {
                    zal(r4);
                    return;
                }
                isReady();
                com.google.android.gms.common.internal.F.i("Results have already been set", !isReady());
                com.google.android.gms.common.internal.F.i("Result has already been consumed", !this.zal);
                b(r4);
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final void setResultCallback(com.google.android.gms.common.api.t tVar) {
        synchronized (this.zae) {
            try {
                if (tVar == null) {
                    this.zah = null;
                    return;
                }
                boolean z4 = true;
                com.google.android.gms.common.internal.F.i("Result has already been consumed.", !this.zal);
                if (this.zap != null) {
                    z4 = false;
                }
                com.google.android.gms.common.internal.F.i("Cannot set callbacks if then() has been called.", z4);
                if (isCanceled()) {
                    return;
                }
                if (isReady()) {
                    this.zab.a(tVar, a());
                } else {
                    this.zah = tVar;
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final <S extends com.google.android.gms.common.api.s> com.google.android.gms.common.api.v then(com.google.android.gms.common.api.u uVar) {
        S s4;
        com.google.android.gms.common.internal.F.i("Result has already been consumed.", !this.zal);
        synchronized (this.zae) {
            try {
                com.google.android.gms.common.internal.F.i("Cannot call then() twice.", this.zap == null);
                com.google.android.gms.common.internal.F.i("Cannot call then() if callbacks are set.", this.zah == null);
                com.google.android.gms.common.internal.F.i("Cannot call then() if result was canceled.", !this.zam);
                this.zaq = true;
                this.zap = new S(this.zac);
                S s5 = this.zap;
                synchronized (s5.f3436b) {
                    s4 = new S(s5.f3437c);
                    s5.f3435a = s4;
                }
                if (isReady()) {
                    this.zab.a(this.zap, a());
                } else {
                    this.zah = this.zap;
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return s4;
    }

    public final void zak() {
        boolean z4 = true;
        if (!this.zaq && !zaa.get().booleanValue()) {
            z4 = false;
        }
        this.zaq = z4;
    }

    public final boolean zam() {
        boolean zIsCanceled;
        synchronized (this.zae) {
            try {
                if (this.zac.get() == null || !this.zaq) {
                    cancel();
                }
                zIsCanceled = isCanceled();
            } catch (Throwable th) {
                throw th;
            }
        }
        return zIsCanceled;
    }

    public final void zan(T t4) {
        this.zai.set(t4);
    }

    @Override // com.google.android.gms.common.api.q
    public final R await(long j4, TimeUnit timeUnit) {
        if (j4 > 0) {
            com.google.android.gms.common.internal.F.f("await must not be called on the UI thread when time is greater than zero.");
        }
        com.google.android.gms.common.internal.F.i("Result has already been consumed.", !this.zal);
        com.google.android.gms.common.internal.F.i("Cannot await if then() has been called.", this.zap == null);
        try {
            if (!this.zaf.await(j4, timeUnit)) {
                forceFailureUnlessReady(Status.f3375o);
            }
        } catch (InterruptedException unused) {
            forceFailureUnlessReady(Status.f3373m);
        }
        com.google.android.gms.common.internal.F.i("Result is not ready.", isReady());
        return (R) a();
    }

    public final void setResultCallback(com.google.android.gms.common.api.t tVar, long j4, TimeUnit timeUnit) {
        synchronized (this.zae) {
            try {
                if (tVar == null) {
                    this.zah = null;
                    return;
                }
                boolean z4 = true;
                com.google.android.gms.common.internal.F.i("Result has already been consumed.", !this.zal);
                if (this.zap != null) {
                    z4 = false;
                }
                com.google.android.gms.common.internal.F.i("Cannot set callbacks if then() has been called.", z4);
                if (isCanceled()) {
                    return;
                }
                if (isReady()) {
                    this.zab.a(tVar, a());
                } else {
                    this.zah = tVar;
                    HandlerC0257e handlerC0257e = this.zab;
                    handlerC0257e.sendMessageDelayed(handlerC0257e.obtainMessage(2, this), timeUnit.toMillis(j4));
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
