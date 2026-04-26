package X3;

import Q3.F;

/* JADX INFO: loaded from: classes.dex */
public final class j extends i {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Runnable f2444c;

    public j(Runnable runnable, long j4, boolean z4) {
        super(j4, z4);
        this.f2444c = runnable;
    }

    @Override // java.lang.Runnable
    public final void run() {
        this.f2444c.run();
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("Task[");
        Runnable runnable = this.f2444c;
        sb.append(runnable.getClass().getSimpleName());
        sb.append('@');
        sb.append(F.l(runnable));
        sb.append(", ");
        sb.append(this.f2442a);
        sb.append(", ");
        sb.append(this.f2443b ? "Blocking" : "Non-blocking");
        sb.append(']');
        return sb.toString();
    }
}
