package l1;

import android.content.Context;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class f implements InterfaceC0634a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5596a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f5597b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f5598c;

    public /* synthetic */ f(int i4, Object obj, Object obj2) {
        this.f5596a = i4;
        this.f5597b = obj;
        this.f5598c = obj2;
    }

    @Override // q1.InterfaceC0634a
    public final Object get() {
        switch (this.f5596a) {
            case 0:
                g gVar = (g) this.f5597b;
                gVar.getClass();
                C0522a c0522a = (C0522a) this.f5598c;
                return c0522a.f5592d.e(new R0.k(c0522a, gVar));
            default:
                return new p1.g((Context) this.f5597b, (String) this.f5598c);
        }
    }
}
