package Q;

import J3.i;
import java.util.LinkedHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class c extends b {
    public c() {
        this(a.f1508b);
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public c(b bVar) {
        super(0);
        i.e(bVar, "initialExtras");
        ((LinkedHashMap) this.f1509a).putAll((LinkedHashMap) bVar.f1509a);
    }
}
