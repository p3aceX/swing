package l3;

import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: l3.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0537n implements T3.d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5701a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ T3.d f5702b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ L.d f5703c;

    public /* synthetic */ C0537n(T3.d dVar, L.d dVar2, int i4) {
        this.f5701a = i4;
        this.f5702b = dVar;
        this.f5703c = dVar2;
    }

    @Override // T3.d
    public final Object b(T3.e eVar, InterfaceC0762c interfaceC0762c) {
        switch (this.f5701a) {
            case 0:
                Object objB = this.f5702b.b(new C0536m(eVar, this.f5703c, 0), interfaceC0762c);
                if (objB != EnumC0789a.f6999a) {
                    break;
                }
                break;
            case 1:
                Object objB2 = this.f5702b.b(new C0536m(eVar, this.f5703c, 1), interfaceC0762c);
                if (objB2 != EnumC0789a.f6999a) {
                    break;
                }
                break;
            case 2:
                Object objB3 = this.f5702b.b(new C0536m(eVar, this.f5703c, 2), interfaceC0762c);
                if (objB3 != EnumC0789a.f6999a) {
                    break;
                }
                break;
            default:
                Object objB4 = this.f5702b.b(new C0536m(eVar, this.f5703c, 3), interfaceC0762c);
                if (objB4 != EnumC0789a.f6999a) {
                    break;
                }
                break;
        }
        return w3.i.f6729a;
    }
}
