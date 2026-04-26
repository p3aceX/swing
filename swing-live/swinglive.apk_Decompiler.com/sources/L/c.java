package L;

import A3.j;
import I3.p;
import e1.AbstractC0367g;
import java.util.concurrent.atomic.AtomicBoolean;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class c extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f863a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f864b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ j f865c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public c(p pVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f865c = (j) pVar;
    }

    /* JADX WARN: Type inference failed for: r1v0, types: [A3.j, I3.p] */
    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        c cVar = new c(this.f865c, interfaceC0762c);
        cVar.f864b = obj;
        return cVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((c) create((b) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    /* JADX WARN: Type inference failed for: r1v1, types: [A3.j, I3.p] */
    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f863a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            b bVar = (b) this.f864b;
            this.f863a = 1;
            obj = this.f865c.invoke(bVar, this);
            if (obj == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        b bVar2 = (b) obj;
        J3.i.c(bVar2, "null cannot be cast to non-null type androidx.datastore.preferences.core.MutablePreferences");
        ((AtomicBoolean) bVar2.f862b.f6969b).set(true);
        return bVar2;
    }
}
