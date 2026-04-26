package n3;

import Q3.D;
import e1.AbstractC0367g;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.nio.channels.spi.AbstractSelector;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: n3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0565a extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractSelector f5890a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public e f5891b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public AbstractSelector f5892c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5893d;
    public final /* synthetic */ e e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0565a(e eVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.e = eVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C0565a(this.e, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0565a) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r0v11, types: [java.nio.channels.spi.AbstractSelector] */
    /* JADX WARN: Type inference failed for: r0v12 */
    /* JADX WARN: Type inference failed for: r0v13 */
    /* JADX WARN: Type inference failed for: r0v14 */
    /* JADX WARN: Type inference failed for: r0v15 */
    /* JADX WARN: Type inference failed for: r0v4 */
    /* JADX WARN: Type inference failed for: r0v6, types: [java.nio.channels.spi.AbstractSelector] */
    /* JADX WARN: Type inference failed for: r0v7, types: [java.nio.channels.spi.AbstractSelector] */
    /* JADX WARN: Type inference failed for: r0v9 */
    /* JADX WARN: Type inference failed for: r2v0 */
    /* JADX WARN: Type inference failed for: r2v1, types: [java.io.Closeable] */
    /* JADX WARN: Type inference failed for: r2v10 */
    /* JADX WARN: Type inference failed for: r2v11 */
    /* JADX WARN: Type inference failed for: r2v2 */
    /* JADX WARN: Type inference failed for: r2v4 */
    /* JADX WARN: Type inference failed for: r2v5 */
    /* JADX WARN: Type inference failed for: r2v6, types: [java.io.Closeable] */
    /* JADX WARN: Type inference failed for: r2v7 */
    /* JADX WARN: Type inference failed for: r2v8, types: [java.nio.channels.spi.AbstractSelector] */
    /* JADX WARN: Type inference failed for: r2v9 */
    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws IllegalAccessException, IOException, InvocationTargetException {
        e eVar;
        Throwable th;
        ?? r02;
        ?? r22;
        ?? r23;
        ?? r03;
        ?? r04;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f5893d;
        ?? r24 = 1;
        try {
            if (i4 == 0) {
                AbstractC0367g.M(obj);
                eVar = this.e;
                AbstractSelector abstractSelectorOpenSelector = eVar.f5906a.openSelector();
                if (abstractSelectorOpenSelector == null) {
                    throw new IllegalStateException("openSelector() = null");
                }
                eVar.selectorRef = abstractSelectorOpenSelector;
                try {
                    m mVar = eVar.f5910f;
                    this.f5890a = abstractSelectorOpenSelector;
                    this.f5891b = eVar;
                    this.f5892c = abstractSelectorOpenSelector;
                    this.f5893d = 1;
                    if (e.a(eVar, mVar, abstractSelectorOpenSelector, this) == enumC0789a) {
                        return enumC0789a;
                    }
                    AbstractSelector abstractSelector = abstractSelectorOpenSelector;
                    r22 = abstractSelector;
                    r04 = abstractSelector;
                    eVar.closed = true;
                    eVar.f5910f.b();
                    eVar.selectorRef = null;
                    r03 = r04;
                    r23 = r22;
                } catch (Throwable th2) {
                    r24 = abstractSelectorOpenSelector;
                    th = th2;
                    r02 = r24;
                    eVar.closed = true;
                    m mVar2 = eVar.f5910f;
                    mVar2.b();
                    e.f(r02, th);
                    eVar.closed = true;
                    mVar2.b();
                    eVar.selectorRef = null;
                    r03 = r02;
                    r23 = r24;
                }
            } else {
                if (i4 != 1) {
                    throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                }
                r02 = this.f5892c;
                eVar = this.f5891b;
                r24 = this.f5890a;
                try {
                    AbstractC0367g.M(obj);
                    r04 = r02;
                    r22 = r24;
                    eVar.closed = true;
                    eVar.f5910f.b();
                    eVar.selectorRef = null;
                    r03 = r04;
                    r23 = r22;
                } catch (Throwable th3) {
                    th = th3;
                    try {
                        eVar.closed = true;
                        m mVar22 = eVar.f5910f;
                        mVar22.b();
                        e.f(r02, th);
                        eVar.closed = true;
                        mVar22.b();
                        eVar.selectorRef = null;
                        r03 = r02;
                        r23 = r24;
                    } catch (Throwable th4) {
                        eVar.closed = true;
                        eVar.f5910f.b();
                        eVar.selectorRef = null;
                        e.f(r02, null);
                        throw th4;
                    }
                }
            }
            e.f(r03, null);
            while (true) {
                q qVar = (q) eVar.f5910f.d();
                if (qVar == null) {
                    H0.a.d(r23, null);
                    return w3.i.f6729a;
                }
                e.g(qVar, new S3.p("Failed to apply interest: selector closed"));
            }
        } finally {
        }
    }
}
