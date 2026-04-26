package j;

import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class e implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ f f5045a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ k f5046b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ j f5047c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ C0779j f5048d;

    public e(C0779j c0779j, f fVar, k kVar, j jVar) {
        this.f5048d = c0779j;
        this.f5045a = fVar;
        this.f5046b = kVar;
        this.f5047c = jVar;
    }

    @Override // java.lang.Runnable
    public final void run() {
        f fVar = this.f5045a;
        if (fVar != null) {
            C0779j c0779j = this.f5048d;
            ((g) c0779j.f6969b).f5057F = true;
            fVar.f5050b.c(false);
            ((g) c0779j.f6969b).f5057F = false;
        }
        k kVar = this.f5046b;
        if (kVar.isEnabled() && kVar.hasSubMenu()) {
            this.f5047c.p(kVar, null, 4);
        }
    }
}
