package s3;

import A3.j;
import I3.p;
import Q3.D;
import S3.e;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: s3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0665a extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6493a;

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C0665a(2, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0665a) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f6493a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
            return obj;
        }
        AbstractC0367g.M(obj);
        e eVar = AbstractC0668d.f6507b;
        this.f6493a = 1;
        Object objY = eVar.y(this);
        return objY == enumC0789a ? enumC0789a : objY;
    }
}
