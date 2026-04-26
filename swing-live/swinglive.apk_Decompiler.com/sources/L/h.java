package L;

import A3.j;
import I3.p;
import e1.AbstractC0367g;
import java.util.LinkedHashMap;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class h extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f869a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f870b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ j f871c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public h(p pVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f871c = (j) pVar;
    }

    /* JADX WARN: Type inference failed for: r1v0, types: [A3.j, I3.p] */
    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        h hVar = new h(this.f871c, interfaceC0762c);
        hVar.f870b = obj;
        return hVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((h) create((b) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    /* JADX WARN: Type inference failed for: r5v5, types: [A3.j, I3.p] */
    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f869a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            b bVar = (b) this.f870b;
            AbstractC0367g.M(obj);
            return bVar;
        }
        AbstractC0367g.M(obj);
        b bVar2 = new b(new LinkedHashMap(((b) this.f870b).a()), false);
        this.f870b = bVar2;
        this.f869a = 1;
        return this.f871c.invoke(bVar2, this) == enumC0789a ? enumC0789a : bVar2;
    }
}
