package l1;

import java.util.Set;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public interface b {
    default Object a(Class cls) {
        return b(r.a(cls));
    }

    default Object b(r rVar) {
        InterfaceC0634a interfaceC0634aF = f(rVar);
        if (interfaceC0634aF == null) {
            return null;
        }
        return interfaceC0634aF.get();
    }

    default InterfaceC0634a c(Class cls) {
        return f(r.a(cls));
    }

    default Set d(r rVar) {
        return (Set) g(rVar).get();
    }

    InterfaceC0634a f(r rVar);

    InterfaceC0634a g(r rVar);
}
