package k1;

import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.internal.p002firebaseauthapi.zzac;
import com.google.android.gms.internal.p002firebaseauthapi.zzxv;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public abstract class k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0.a f5534a = new C0.a("JSONParser", new String[0]);

    public static ArrayList a(JSONArray jSONArray) throws JSONException {
        ArrayList arrayList = new ArrayList();
        for (int i4 = 0; i4 < jSONArray.length(); i4++) {
            Object objC = jSONArray.get(i4);
            if (objC instanceof JSONArray) {
                objC = a((JSONArray) objC);
            } else if (objC instanceof JSONObject) {
                objC = c((JSONObject) objC);
            }
            arrayList.add(objC);
        }
        return arrayList;
    }

    public static Map b(String str) {
        F.d(str);
        List<String> listZza = zzac.zza('.').zza((CharSequence) str);
        int size = listZza.size();
        C0.a aVar = f5534a;
        if (size < 2) {
            aVar.c(B1.a.m("Invalid idToken ", str), new Object[0]);
            return new HashMap();
        }
        String str2 = listZza.get(1);
        try {
            n.b bVarD = d(new String(str2 == null ? null : Base64.decode(str2, 11), "UTF-8"));
            return bVarD == null ? new HashMap() : bVarD;
        } catch (UnsupportedEncodingException e) {
            aVar.b("Unable to decode token", e, new Object[0]);
            return new HashMap();
        }
    }

    public static n.b c(JSONObject jSONObject) throws JSONException {
        n.b bVar = new n.b();
        Iterator<String> itKeys = jSONObject.keys();
        while (itKeys.hasNext()) {
            String next = itKeys.next();
            Object objC = jSONObject.get(next);
            if (objC instanceof JSONArray) {
                objC = a((JSONArray) objC);
            } else if (objC instanceof JSONObject) {
                objC = c((JSONObject) objC);
            }
            bVar.put(next, objC);
        }
        return bVar;
    }

    public static n.b d(String str) {
        if (TextUtils.isEmpty(str)) {
            return null;
        }
        try {
            JSONObject jSONObject = new JSONObject(str);
            if (jSONObject != JSONObject.NULL) {
                return c(jSONObject);
            }
            return null;
        } catch (Exception e) {
            Log.d("JSONParser", "Failed to parse JSONObject into Map.");
            throw new zzxv(e);
        }
    }
}
