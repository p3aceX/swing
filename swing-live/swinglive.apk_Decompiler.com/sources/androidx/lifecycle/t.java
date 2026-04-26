package androidx.lifecycle;

/* JADX INFO: loaded from: classes.dex */
public abstract class t {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final v f3085a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f3086b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f3087c = -1;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ u f3088d;

    public t(u uVar, v vVar) {
        this.f3088d = uVar;
        this.f3085a = vVar;
    }

    public final void b(boolean z4) {
        if (z4 == this.f3086b) {
            return;
        }
        this.f3086b = z4;
        int i4 = z4 ? 1 : -1;
        u uVar = this.f3088d;
        int i5 = uVar.f3092c;
        uVar.f3092c = i4 + i5;
        if (!uVar.f3093d) {
            uVar.f3093d = true;
            while (true) {
                try {
                    int i6 = uVar.f3092c;
                    if (i5 == i6) {
                        break;
                    }
                    boolean z5 = i5 == 0 && i6 > 0;
                    boolean z6 = i5 > 0 && i6 == 0;
                    if (z5) {
                        uVar.e();
                    } else if (z6) {
                        uVar.f();
                    }
                    i5 = i6;
                } catch (Throwable th) {
                    uVar.f3093d = false;
                    throw th;
                }
            }
            uVar.f3093d = false;
        }
        if (this.f3086b) {
            uVar.c(this);
        }
    }

    public void c() {
    }

    public boolean d(n nVar) {
        return false;
    }

    public abstract boolean e();
}
