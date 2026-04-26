package O2;

import a.AbstractC0184a;
import java.nio.ByteBuffer;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

/* JADX INFO: loaded from: classes.dex */
public final class j implements l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final j f1453a = new j();

    @Override // O2.l
    public final Object a(ByteBuffer byteBuffer) {
        if (byteBuffer == null) {
            return null;
        }
        try {
            s.f1460b.getClass();
            JSONTokener jSONTokener = new JSONTokener(s.c(byteBuffer));
            Object objNextValue = jSONTokener.nextValue();
            if (jSONTokener.more()) {
                throw new IllegalArgumentException("Invalid JSON");
            }
            return objNextValue;
        } catch (JSONException e) {
            throw new IllegalArgumentException("Invalid JSON", e);
        }
    }

    @Override // O2.l
    public final ByteBuffer b(Object obj) {
        if (obj == null) {
            return null;
        }
        Object objA0 = AbstractC0184a.a0(obj);
        if (objA0 instanceof String) {
            s sVar = s.f1460b;
            String strQuote = JSONObject.quote((String) objA0);
            sVar.getClass();
            return s.d(strQuote);
        }
        s sVar2 = s.f1460b;
        String string = objA0.toString();
        sVar2.getClass();
        return s.d(string);
    }
}
