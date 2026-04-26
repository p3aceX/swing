package L;

import I3.l;
import J3.i;
import J3.j;
import java.util.Map;
import x3.AbstractC0726f;

/* JADX INFO: loaded from: classes.dex */
public final class a extends j implements l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final a f860a = new a(1);

    @Override // I3.l
    public final Object invoke(Object obj) {
        Map.Entry entry = (Map.Entry) obj;
        i.e(entry, "entry");
        Object value = entry.getValue();
        return "  " + ((d) entry.getKey()).f866a + " = " + (value instanceof byte[] ? AbstractC0726f.i0((byte[]) value, ", ", null, 56) : String.valueOf(entry.getValue()));
    }
}
