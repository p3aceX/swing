package D2;

import android.os.Build;
import java.util.Iterator;

/* JADX INFO: renamed from: D2.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0030e implements io.flutter.embedding.engine.renderer.k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f189a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f190b;

    public /* synthetic */ C0030e(Object obj, int i4) {
        this.f189a = i4;
        this.f190b = obj;
    }

    @Override // io.flutter.embedding.engine.renderer.k
    public final void a() {
        switch (this.f189a) {
            case 0:
                C0032g c0032g = (C0032g) this.f190b;
                c0032g.f193a.getClass();
                c0032g.f199h = false;
                break;
            case 1:
                r rVar = (r) this.f190b;
                rVar.f245o = false;
                Iterator it = rVar.f244n.iterator();
                while (it.hasNext()) {
                    ((io.flutter.embedding.engine.renderer.k) it.next()).a();
                }
                break;
            case 2:
                break;
            default:
                ((io.flutter.embedding.engine.renderer.j) this.f190b).f4538d = false;
                break;
        }
    }

    @Override // io.flutter.embedding.engine.renderer.k
    public final void b() {
        switch (this.f189a) {
            case 0:
                C0032g c0032g = (C0032g) this.f190b;
                AbstractActivityC0029d abstractActivityC0029d = c0032g.f193a;
                if (Build.VERSION.SDK_INT >= 29) {
                    abstractActivityC0029d.reportFullyDrawn();
                } else {
                    abstractActivityC0029d.getClass();
                }
                c0032g.f199h = true;
                c0032g.f200i = true;
                break;
            case 1:
                r rVar = (r) this.f190b;
                rVar.f245o = true;
                Iterator it = rVar.f244n.iterator();
                while (it.hasNext()) {
                    ((io.flutter.embedding.engine.renderer.k) it.next()).b();
                }
                break;
            case 2:
                N n4 = (N) this.f190b;
                n4.f173a.setAlpha(1.0f);
                io.flutter.embedding.engine.renderer.j jVar = n4.f174b;
                if (jVar != null) {
                    jVar.g(this);
                }
                break;
            default:
                ((io.flutter.embedding.engine.renderer.j) this.f190b).f4538d = true;
                break;
        }
    }

    private final void c() {
    }
}
