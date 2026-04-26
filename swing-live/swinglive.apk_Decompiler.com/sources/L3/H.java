package l3;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class H extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5649a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ L.d f5650b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ long f5651c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public H(L.d dVar, long j4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5650b = dVar;
        this.f5651c = j4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        H h4 = new H(this.f5650b, this.f5651c, interfaceC0762c);
        h4.f5649a = obj;
        return h4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        H h4 = (H) create((L.b) obj, (InterfaceC0762c) obj2);
        w3.i iVar = w3.i.f6729a;
        h4.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        ((L.b) this.f5649a).d(this.f5650b, new Long(this.f5651c));
        return w3.i.f6729a;
    }
}
