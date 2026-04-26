package O2;

import D2.v;
import a.AbstractC0184a;
import java.nio.ByteBuffer;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

/* JADX INFO: loaded from: classes.dex */
public final class k implements n {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final k f1454a = new k();

    @Override // O2.n
    public ByteBuffer a(v vVar) {
        try {
            JSONObject jSONObject = new JSONObject();
            jSONObject.put("method", (String) vVar.f260b);
            jSONObject.put("args", AbstractC0184a.a0(vVar.f261c));
            Object objA0 = AbstractC0184a.a0(jSONObject);
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
        } catch (JSONException e) {
            throw new IllegalArgumentException("Invalid JSON", e);
        }
    }

    @Override // O2.n
    public ByteBuffer b(Object obj) {
        JSONArray jSONArrayPut = new JSONArray().put(AbstractC0184a.a0(obj));
        if (jSONArrayPut == null) {
            return null;
        }
        Object objA0 = AbstractC0184a.a0(jSONArrayPut);
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

    @Override // O2.n
    public v c(ByteBuffer byteBuffer) {
        Object objNextValue;
        Object obj = null;
        if (byteBuffer == null) {
            objNextValue = null;
        } else {
            try {
                try {
                    s.f1460b.getClass();
                    JSONTokener jSONTokener = new JSONTokener(s.c(byteBuffer));
                    objNextValue = jSONTokener.nextValue();
                    if (jSONTokener.more()) {
                        throw new IllegalArgumentException("Invalid JSON");
                    }
                } catch (JSONException e) {
                    throw new IllegalArgumentException("Invalid JSON", e);
                }
            } catch (JSONException e4) {
                throw new IllegalArgumentException("Invalid JSON", e4);
            }
        }
        if (objNextValue instanceof JSONObject) {
            JSONObject jSONObject = (JSONObject) objNextValue;
            Object obj2 = jSONObject.get("method");
            Object objOpt = jSONObject.opt("args");
            if (objOpt != JSONObject.NULL) {
                obj = objOpt;
            }
            if (obj2 instanceof String) {
                return new v((String) obj2, obj, 15, false);
            }
        }
        throw new IllegalArgumentException("Invalid method call: " + objNextValue);
    }

    @Override // O2.n
    public Object d(ByteBuffer byteBuffer) {
        try {
            try {
                s.f1460b.getClass();
                JSONTokener jSONTokener = new JSONTokener(s.c(byteBuffer));
                Object objNextValue = jSONTokener.nextValue();
                if (jSONTokener.more()) {
                    throw new IllegalArgumentException("Invalid JSON");
                }
                if (objNextValue instanceof JSONArray) {
                    JSONArray jSONArray = (JSONArray) objNextValue;
                    Object obj = null;
                    if (jSONArray.length() == 1) {
                        Object objOpt = jSONArray.opt(0);
                        if (objOpt == JSONObject.NULL) {
                            return null;
                        }
                        return objOpt;
                    }
                    if (jSONArray.length() == 3) {
                        Object obj2 = jSONArray.get(0);
                        Object objOpt2 = jSONArray.opt(1);
                        Object obj3 = JSONObject.NULL;
                        if (objOpt2 == obj3) {
                            objOpt2 = null;
                        }
                        Object objOpt3 = jSONArray.opt(2);
                        if (objOpt3 != obj3) {
                            obj = objOpt3;
                        }
                        if ((obj2 instanceof String) && (objOpt2 == null || (objOpt2 instanceof String))) {
                            throw new i(obj, (String) obj2, (String) objOpt2);
                        }
                    }
                }
                throw new IllegalArgumentException("Invalid envelope: " + objNextValue);
            } catch (JSONException e) {
                throw new IllegalArgumentException("Invalid JSON", e);
            }
        } catch (JSONException e4) {
            throw new IllegalArgumentException("Invalid JSON", e4);
        }
    }

    @Override // O2.n
    public ByteBuffer e(String str, String str2) {
        JSONArray jSONArrayPut = new JSONArray().put("error").put(AbstractC0184a.a0(str)).put(JSONObject.NULL).put(AbstractC0184a.a0(str2));
        if (jSONArrayPut == null) {
            return null;
        }
        Object objA0 = AbstractC0184a.a0(jSONArrayPut);
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

    @Override // O2.n
    public ByteBuffer f(Object obj, String str, String str2) {
        JSONArray jSONArrayPut = new JSONArray().put(str).put(AbstractC0184a.a0(str2)).put(AbstractC0184a.a0(obj));
        if (jSONArrayPut == null) {
            return null;
        }
        Object objA0 = AbstractC0184a.a0(jSONArrayPut);
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
