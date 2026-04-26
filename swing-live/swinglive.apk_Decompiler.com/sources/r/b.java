package R;

import D2.B;
import androidx.lifecycle.F;
import n.l;
import y0.C0740d;

/* JADX INFO: loaded from: classes.dex */
public class b extends F {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final l f1677c = new l();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f1678d = false;

    @Override // androidx.lifecycle.F
    public final void a() {
        l lVar = this.f1677c;
        int i4 = lVar.f5860c;
        for (int i5 = 0; i5 < i4; i5++) {
            a aVar = (a) lVar.f5859b[i5];
            C0740d c0740d = aVar.f1674l;
            c0740d.a();
            c0740d.f6815c = true;
            B b5 = aVar.f1676n;
            if (b5 != null) {
                aVar.g(b5);
            }
            a aVar2 = c0740d.f6813a;
            if (aVar2 == null) {
                throw new IllegalStateException("No listener register");
            }
            if (aVar2 != aVar) {
                throw new IllegalArgumentException("Attempting to unregister the wrong listener");
            }
            c0740d.f6813a = null;
            if (b5 != null) {
                boolean z4 = b5.f155b;
            }
            c0740d.f6816d = true;
            c0740d.f6814b = false;
            c0740d.f6815c = false;
            c0740d.e = false;
        }
        int i6 = lVar.f5860c;
        Object[] objArr = lVar.f5859b;
        for (int i7 = 0; i7 < i6; i7++) {
            objArr[i7] = null;
        }
        lVar.f5860c = 0;
    }
}
