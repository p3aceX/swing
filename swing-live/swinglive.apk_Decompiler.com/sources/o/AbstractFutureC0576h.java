package o;

import com.google.crypto.tink.shaded.protobuf.S;
import e1.k;
import java.util.Locale;
import java.util.concurrent.CancellationException;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import java.util.concurrent.locks.LockSupport;
import java.util.logging.Level;
import java.util.logging.Logger;

/* JADX INFO: renamed from: o.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractFutureC0576h implements Future {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final boolean f5951d = Boolean.parseBoolean(System.getProperty("guava.concurrent.generate_cancellation_cause", "false"));
    public static final Logger e = Logger.getLogger(AbstractFutureC0576h.class.getName());

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final k f5952f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final Object f5953m;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public volatile Object f5954a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public volatile C0572d f5955b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public volatile C0575g f5956c;

    static {
        k c0574f;
        try {
            c0574f = new C0573e(AtomicReferenceFieldUpdater.newUpdater(C0575g.class, Thread.class, "a"), AtomicReferenceFieldUpdater.newUpdater(C0575g.class, C0575g.class, "b"), AtomicReferenceFieldUpdater.newUpdater(AbstractFutureC0576h.class, C0575g.class, "c"), AtomicReferenceFieldUpdater.newUpdater(AbstractFutureC0576h.class, C0572d.class, "b"), AtomicReferenceFieldUpdater.newUpdater(AbstractFutureC0576h.class, Object.class, "a"));
            th = null;
        } catch (Throwable th) {
            th = th;
            c0574f = new C0574f();
        }
        f5952f = c0574f;
        if (th != null) {
            e.log(Level.SEVERE, "SafeAtomicHelper is broken!", th);
        }
        f5953m = new Object();
    }

    public static void c(AbstractFutureC0576h abstractFutureC0576h) {
        C0575g c0575g;
        C0572d c0572d;
        do {
            c0575g = abstractFutureC0576h.f5956c;
        } while (!f5952f.f(abstractFutureC0576h, c0575g, C0575g.f5948c));
        while (c0575g != null) {
            Thread thread = c0575g.f5949a;
            if (thread != null) {
                c0575g.f5949a = null;
                LockSupport.unpark(thread);
            }
            c0575g = c0575g.f5950b;
        }
        abstractFutureC0576h.b();
        do {
            c0572d = abstractFutureC0576h.f5955b;
        } while (!f5952f.d(abstractFutureC0576h, c0572d));
        C0572d c0572d2 = null;
        while (c0572d != null) {
            C0572d c0572d3 = c0572d.f5943a;
            c0572d.f5943a = c0572d2;
            c0572d2 = c0572d;
            c0572d = c0572d3;
        }
        while (c0572d2 != null) {
            c0572d2 = c0572d2.f5943a;
            try {
                throw null;
            } catch (RuntimeException e4) {
                e.log(Level.SEVERE, "RuntimeException while executing runnable null with executor null", (Throwable) e4);
            }
        }
    }

    public static Object d(Object obj) throws ExecutionException {
        if (obj instanceof C0569a) {
            CancellationException cancellationException = ((C0569a) obj).f5940b;
            CancellationException cancellationException2 = new CancellationException("Task was cancelled.");
            cancellationException2.initCause(cancellationException);
            throw cancellationException2;
        }
        if (obj instanceof C0571c) {
            throw new ExecutionException(((C0571c) obj).f5941a);
        }
        if (obj == f5953m) {
            return null;
        }
        return obj;
    }

    public static Object e(AbstractFutureC0576h abstractFutureC0576h) {
        Object obj;
        boolean z4 = false;
        while (true) {
            try {
                obj = abstractFutureC0576h.get();
                break;
            } catch (InterruptedException unused) {
                z4 = true;
            } catch (Throwable th) {
                if (z4) {
                    Thread.currentThread().interrupt();
                }
                throw th;
            }
        }
        if (z4) {
            Thread.currentThread().interrupt();
        }
        return obj;
    }

    public final void a(StringBuilder sb) {
        try {
            Object objE = e(this);
            sb.append("SUCCESS, result=[");
            sb.append(objE == this ? "this future" : String.valueOf(objE));
            sb.append("]");
        } catch (CancellationException unused) {
            sb.append("CANCELLED");
        } catch (RuntimeException e4) {
            sb.append("UNKNOWN, cause=[");
            sb.append(e4.getClass());
            sb.append(" thrown from get()]");
        } catch (ExecutionException e5) {
            sb.append("FAILURE, cause=[");
            sb.append(e5.getCause());
            sb.append("]");
        }
    }

    @Override // java.util.concurrent.Future
    public final boolean cancel(boolean z4) {
        Object obj = this.f5954a;
        if (obj != null) {
            return false;
        }
        if (!f5952f.e(this, obj, f5951d ? new C0569a(z4, new CancellationException("Future.cancel() was called.")) : z4 ? C0569a.f5937c : C0569a.f5938d)) {
            return false;
        }
        c(this);
        return true;
    }

    public final void f(C0575g c0575g) {
        c0575g.f5949a = null;
        while (true) {
            C0575g c0575g2 = this.f5956c;
            if (c0575g2 == C0575g.f5948c) {
                return;
            }
            C0575g c0575g3 = null;
            while (c0575g2 != null) {
                C0575g c0575g4 = c0575g2.f5950b;
                if (c0575g2.f5949a != null) {
                    c0575g3 = c0575g2;
                } else if (c0575g3 != null) {
                    c0575g3.f5950b = c0575g4;
                    if (c0575g3.f5949a == null) {
                        break;
                    }
                } else if (!f5952f.f(this, c0575g2, c0575g4)) {
                    break;
                }
                c0575g2 = c0575g4;
            }
            return;
        }
    }

    @Override // java.util.concurrent.Future
    public final Object get(long j4, TimeUnit timeUnit) throws InterruptedException, TimeoutException {
        long nanos = timeUnit.toNanos(j4);
        if (Thread.interrupted()) {
            throw new InterruptedException();
        }
        Object obj = this.f5954a;
        if (obj != null) {
            return d(obj);
        }
        long jNanoTime = nanos > 0 ? System.nanoTime() + nanos : 0L;
        if (nanos >= 1000) {
            C0575g c0575g = this.f5956c;
            C0575g c0575g2 = C0575g.f5948c;
            if (c0575g != c0575g2) {
                C0575g c0575g3 = new C0575g();
                do {
                    k kVar = f5952f;
                    kVar.B(c0575g3, c0575g);
                    if (kVar.f(this, c0575g, c0575g3)) {
                        do {
                            LockSupport.parkNanos(this, nanos);
                            if (Thread.interrupted()) {
                                f(c0575g3);
                                throw new InterruptedException();
                            }
                            Object obj2 = this.f5954a;
                            if (obj2 != null) {
                                return d(obj2);
                            }
                            nanos = jNanoTime - System.nanoTime();
                        } while (nanos >= 1000);
                        f(c0575g3);
                    } else {
                        c0575g = this.f5956c;
                    }
                } while (c0575g != c0575g2);
            }
            return d(this.f5954a);
        }
        while (nanos > 0) {
            Object obj3 = this.f5954a;
            if (obj3 != null) {
                return d(obj3);
            }
            if (Thread.interrupted()) {
                throw new InterruptedException();
            }
            nanos = jNanoTime - System.nanoTime();
        }
        String string = toString();
        String string2 = timeUnit.toString();
        Locale locale = Locale.ROOT;
        String lowerCase = string2.toLowerCase(locale);
        String strF = "Waited " + j4 + " " + timeUnit.toString().toLowerCase(locale);
        if (nanos + 1000 < 0) {
            String strF2 = S.f(strF, " (plus ");
            long j5 = -nanos;
            long jConvert = timeUnit.convert(j5, TimeUnit.NANOSECONDS);
            long nanos2 = j5 - timeUnit.toNanos(jConvert);
            boolean z4 = jConvert == 0 || nanos2 > 1000;
            if (jConvert > 0) {
                String strF3 = strF2 + jConvert + " " + lowerCase;
                if (z4) {
                    strF3 = S.f(strF3, ",");
                }
                strF2 = S.f(strF3, " ");
            }
            if (z4) {
                strF2 = strF2 + nanos2 + " nanoseconds ";
            }
            strF = S.f(strF2, "delay)");
        }
        if (isDone()) {
            throw new TimeoutException(S.f(strF, " but future completed as timeout expired"));
        }
        throw new TimeoutException(strF + " for " + string);
    }

    @Override // java.util.concurrent.Future
    public final boolean isCancelled() {
        return this.f5954a instanceof C0569a;
    }

    @Override // java.util.concurrent.Future
    public final boolean isDone() {
        return this.f5954a != null;
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final String toString() {
        String str;
        StringBuilder sb = new StringBuilder();
        sb.append(super.toString());
        sb.append("[status=");
        if (this.f5954a instanceof C0569a) {
            sb.append("CANCELLED");
        } else if (isDone()) {
            a(sb);
        } else {
            try {
                if (this instanceof ScheduledFuture) {
                    str = "remaining delay=[" + ((ScheduledFuture) this).getDelay(TimeUnit.MILLISECONDS) + " ms]";
                } else {
                    str = null;
                }
            } catch (RuntimeException e4) {
                str = "Exception thrown from implementation: " + e4.getClass();
            }
            if (str != null && !str.isEmpty()) {
                sb.append("PENDING, info=[");
                sb.append(str);
                sb.append("]");
            } else if (isDone()) {
                a(sb);
            } else {
                sb.append("PENDING");
            }
        }
        sb.append("]");
        return sb.toString();
    }

    public void b() {
    }

    @Override // java.util.concurrent.Future
    public final Object get() throws InterruptedException {
        Object obj;
        if (!Thread.interrupted()) {
            Object obj2 = this.f5954a;
            if (obj2 != null) {
                return d(obj2);
            }
            C0575g c0575g = this.f5956c;
            C0575g c0575g2 = C0575g.f5948c;
            if (c0575g != c0575g2) {
                C0575g c0575g3 = new C0575g();
                do {
                    k kVar = f5952f;
                    kVar.B(c0575g3, c0575g);
                    if (kVar.f(this, c0575g, c0575g3)) {
                        do {
                            LockSupport.park(this);
                            if (!Thread.interrupted()) {
                                obj = this.f5954a;
                            } else {
                                f(c0575g3);
                                throw new InterruptedException();
                            }
                        } while (obj == null);
                        return d(obj);
                    }
                    c0575g = this.f5956c;
                } while (c0575g != c0575g2);
            }
            return d(this.f5954a);
        }
        throw new InterruptedException();
    }
}
