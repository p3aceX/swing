package io.ktor.network.util;

import A3.j;
import I3.p;
import Q3.D;
import Q3.F;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class b extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4946a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ c f4947b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public b(c cVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4947b = cVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new b(this.f4947b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((b) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    /* JADX WARN: Type inference failed for: r10v16, types: [A3.j, I3.l] */
    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f4946a;
        if (i4 != 0 && i4 != 1) {
            if (i4 != 2) {
                if (i4 != 3) {
                    throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                }
                AbstractC0367g.M(obj);
                return i.f6729a;
            }
            AbstractC0367g.M(obj);
            ?? r10 = this.f4947b.f4950c;
            this.f4946a = 3;
            if (r10.invoke(this) == enumC0789a) {
                return enumC0789a;
            }
            return i.f6729a;
        }
        AbstractC0367g.M(obj);
        while (true) {
            if (this.f4947b.isStarted == 0) {
                c cVar = this.f4947b;
                cVar.lastActivityTime = ((Number) cVar.f4949b.a()).longValue();
            }
            long j4 = this.f4947b.lastActivityTime;
            c cVar2 = this.f4947b;
            long jLongValue = (j4 + cVar2.f4948a) - ((Number) cVar2.f4949b.a()).longValue();
            if (jLongValue > 0 || this.f4947b.isStarted == 0) {
                this.f4946a = 1;
                if (F.h(jLongValue, this) == enumC0789a) {
                    break;
                }
            } else {
                this.f4946a = 2;
                if (F.E(this) == enumC0789a) {
                }
            }
        }
        return enumC0789a;
    }
}
