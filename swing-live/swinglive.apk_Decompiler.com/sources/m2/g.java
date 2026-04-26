package m2;

import A3.j;
import I3.p;
import Q3.D;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class g extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ i f5807a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f5808b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public g(i iVar, int i4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5807a = iVar;
        this.f5808b = i4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new g(this.f5807a, this.f5808b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        g gVar = (g) create((D) obj, (InterfaceC0762c) obj2);
        w3.i iVar = w3.i.f6729a;
        gVar.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        this.f5807a.f5818k.write(this.f5808b);
        return w3.i.f6729a;
    }
}
