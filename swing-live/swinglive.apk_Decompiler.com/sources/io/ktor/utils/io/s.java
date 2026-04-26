package io.ktor.utils.io;

import Q3.y0;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class s extends A3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5010a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ y0 f5011b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public s(y0 y0Var, InterfaceC0762c interfaceC0762c) {
        super(1, interfaceC0762c);
        this.f5011b = y0Var;
    }

    @Override // A3.a
    public final InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        return new s(this.f5011b, interfaceC0762c);
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        return ((s) create((InterfaceC0762c) obj)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f5010a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f5010a = 1;
            if (this.f5011b.y(this) == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        return w3.i.f6729a;
    }
}
