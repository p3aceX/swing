package k;

import androidx.appcompat.widget.SearchView;

/* JADX INFO: loaded from: classes.dex */
public final class U implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5331a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ SearchView f5332b;

    public /* synthetic */ U(SearchView searchView, int i4) {
        this.f5331a = i4;
        this.f5332b = searchView;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f5331a) {
            case 0:
                this.f5332b.q();
                break;
            default:
                G.b bVar = this.f5332b.f2751U;
                if (bVar instanceof f0) {
                    bVar.b(null);
                }
                break;
        }
    }
}
