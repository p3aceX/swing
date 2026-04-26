package i0;

import D2.C0039n;
import I3.p;
import S3.u;
import android.app.Activity;
import e1.AbstractC0367g;
import j0.InterfaceC0450a;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class i extends A3.j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4478a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f4479b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ b f4480c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Activity f4481d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public i(b bVar, Activity activity, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4480c = bVar;
        this.f4481d = activity;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        i iVar = new i(this.f4480c, this.f4481d, interfaceC0762c);
        iVar.f4479b = obj;
        return iVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((i) create((u) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f4478a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            u uVar = (u) this.f4479b;
            C0039n c0039n = new C0039n(uVar, 1);
            b bVar = this.f4480c;
            ((InterfaceC0450a) bVar.f4464b).a(this.f4481d, new V.d(), c0039n);
            K.b bVar2 = new K.b(1, bVar, c0039n);
            this.f4478a = 1;
            if (S3.m.b(uVar, bVar2, this) == enumC0789a) {
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
