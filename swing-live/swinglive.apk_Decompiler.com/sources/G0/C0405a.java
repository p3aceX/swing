package g0;

import A3.j;
import D2.C0039n;
import I.A;
import I3.p;
import Q3.D;
import T3.d;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: g0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0405a extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4295a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ d f4296b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0039n f4297c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0405a(d dVar, C0039n c0039n, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4296b = dVar;
        this.f4297c = c0039n;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C0405a(this.f4296b, this.f4297c, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0405a) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f4295a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            A a5 = new A(this.f4297c, 2);
            this.f4295a = 1;
            if (this.f4296b.b(a5, this) == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        return i.f6729a;
    }
}
