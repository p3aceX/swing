package l3;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: l3.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0533j extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5689a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ L.d f5690b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ String f5691c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0533j(L.d dVar, String str, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5690b = dVar;
        this.f5691c = str;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0533j c0533j = new C0533j(this.f5690b, this.f5691c, interfaceC0762c);
        c0533j.f5689a = obj;
        return c0533j;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        C0533j c0533j = (C0533j) create((L.b) obj, (InterfaceC0762c) obj2);
        w3.i iVar = w3.i.f6729a;
        c0533j.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        ((L.b) this.f5689a).d(this.f5690b, this.f5691c);
        return w3.i.f6729a;
    }
}
