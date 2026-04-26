package m2;

import A3.j;
import I3.p;
import Q3.D;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class f extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ i f5806a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public f(i iVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5806a = iVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new f(this.f5806a, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((f) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        return new Integer(this.f5806a.d0(1).read());
    }
}
