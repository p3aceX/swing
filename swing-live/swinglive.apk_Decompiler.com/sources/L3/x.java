package l3;

import I.InterfaceC0048i;
import android.content.Context;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class x extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public J3.r f5738a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5739b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ String f5740c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ K f5741d;
    public final /* synthetic */ J3.r e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public x(String str, K k4, J3.r rVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5740c = str;
        this.f5741d = k4;
        this.e = rVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new x(this.f5740c, this.f5741d, this.e, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((x) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        J3.r rVar;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f5739b;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            L.d dVar = new L.d(this.f5740c);
            Context context = this.f5741d.f5660a;
            if (context == null) {
                J3.i.g("context");
                throw null;
            }
            C0537n c0537n = new C0537n(((InterfaceC0048i) L.a(context).f104b).q(), dVar, 2);
            J3.r rVar2 = this.e;
            this.f5738a = rVar2;
            this.f5739b = 1;
            Object objC = T3.r.c(c0537n, this);
            if (objC == enumC0789a) {
                return enumC0789a;
            }
            rVar = rVar2;
            obj = objC;
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            rVar = this.f5738a;
            AbstractC0367g.M(obj);
        }
        rVar.f832a = obj;
        return w3.i.f6729a;
    }
}
