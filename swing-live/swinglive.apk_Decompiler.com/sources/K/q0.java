package k;

/* JADX INFO: loaded from: classes.dex */
public final class q0 implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5439a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ r0 f5440b;

    public /* synthetic */ q0(r0 r0Var, int i4) {
        this.f5439a = i4;
        this.f5440b = r0Var;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f5439a) {
            case 0:
                this.f5440b.c(false);
                break;
            default:
                this.f5440b.a();
                break;
        }
    }
}
