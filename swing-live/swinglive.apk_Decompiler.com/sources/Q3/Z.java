package Q3;

import java.lang.reflect.InvocationTargetException;
import x3.C0725e;

/* JADX INFO: loaded from: classes.dex */
public abstract class Z extends A {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ int f1609f = 0;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public long f1610c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f1611d;
    public C0725e e;

    public final void E(boolean z4) {
        long j4 = this.f1610c - (z4 ? 4294967296L : 1L);
        this.f1610c = j4;
        if (j4 <= 0 && this.f1611d) {
            shutdown();
        }
    }

    public final void F(N n4) {
        C0725e c0725e = this.e;
        if (c0725e == null) {
            c0725e = new C0725e();
            this.e = c0725e;
        }
        c0725e.addLast(n4);
    }

    public abstract Thread G();

    public final void H(boolean z4) {
        this.f1610c = (z4 ? 4294967296L : 1L) + this.f1610c;
        if (z4) {
            return;
        }
        this.f1611d = true;
    }

    public abstract long I();

    public final boolean J() throws IllegalAccessException, InvocationTargetException {
        C0725e c0725e = this.e;
        if (c0725e == null) {
            return false;
        }
        N n4 = (N) (c0725e.isEmpty() ? null : c0725e.removeFirst());
        if (n4 == null) {
            return false;
        }
        n4.run();
        return true;
    }

    public void K(long j4, W w4) {
        G.f1585p.P(j4, w4);
    }

    public abstract void shutdown();
}
