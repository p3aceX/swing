package y1;

import A3.j;
import I3.p;
import Q3.D;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: y1.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0756f extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ I3.a f6853a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0756f(I3.a aVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6853a = aVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C0756f(this.f6853a, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        C0756f c0756f = (C0756f) create((D) obj, (InterfaceC0762c) obj2);
        i iVar = i.f6729a;
        c0756f.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        this.f6853a.a();
        return i.f6729a;
    }
}
