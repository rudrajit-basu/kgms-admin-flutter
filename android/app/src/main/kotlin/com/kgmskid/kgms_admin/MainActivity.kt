package com.kgmskid.kgms_admin

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

import com.google.firebase.ktx.Firebase
import com.google.firebase.ktx.initialize
import com.google.firebase.storage.ktx.storage
import org.json.JSONArray
import org.json.JSONException
import com.google.firebase.storage.StorageMetadata
import org.json.JSONObject

class MainActivity: FlutterActivity() {
	private val CHANNEL = "flutter.kgmskid.kgms_admin/firestorage"
	private val storage = Firebase.storage

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
	      call, result ->
	      if(call.method == "getMediaStorage"){
	      	val subDir = call.arguments as String
			val listRef = storage.reference.child("kgms-images").child(subDir)
			val jsonArr = JSONArray()
	      	listRef.listAll()
	      		.addOnSuccessListener { listResult ->
	      			listResult.items.forEach { item ->
	      			
		      			try{
	      					jsonArr.put(item.getName())
	      				} catch (e: JSONException){
	      					 println(e)
	      					 result.error("Kotlin Side", "JSON create", null)
	      				}

	      			}
	      			result.success(jsonArr.toString())
	      		}
	      		.addOnFailureListener {
	      			result.error("Kotlin Side", "FireStorage", null)
	      		}
	      }
	    }
    }
}
