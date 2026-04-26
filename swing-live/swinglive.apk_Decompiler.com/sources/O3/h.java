package O3;

import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class h implements Iterable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ P3.c f1468a;

    public h(P3.c cVar) {
        this.f1468a = cVar;
    }

    @Override // java.lang.Iterable
    public final Iterator iterator() {
        return new P3.b(this.f1468a);
    }
}
